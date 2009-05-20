#include <google/sparse_hash_map>
#include <google/dense_hash_map>
#include <google/sparse_hash_set>
#include <google/dense_hash_set>

#include <map>
#include <set>

#include <cstring>

#ifdef __GNUC__
#include <ext/hash_map>
#include <ext/hash_set>
namespace std {
  using namespace __gnu_cxx;
}
#endif

#include "sparsehash_internal.h"

namespace {

struct sparsehash_equal_key {
  bool operator() (const VALUE &x, const VALUE &y) const {
    if (TYPE(x) == T_STRING && TYPE(y) == T_STRING) {
      const char *x_ptr = RSTRING_PTR(x);
      const char *y_ptr = RSTRING_PTR(y);
      long x_len = RSTRING_LEN(x);
      long y_len = RSTRING_LEN(y);
      return (x_len == y_len) && (x_len == 0 || (strncmp(x_ptr, y_ptr, x_len) == 0));
    } else {
      return (x == y);
    }
  }
};

struct sparsehash_hash {
  size_t operator() (const VALUE &x) const {
    return (TYPE(x) == T_STRING) ? rb_str_hash(x) : x;
  }
};

struct stl_key_compare {
  bool operator() (const VALUE &x, const VALUE &y) const {
    return (rb_str_hash(x) < rb_str_hash(y));
  }
};

typedef google::sparse_hash_map<VALUE, VALUE, sparsehash_hash, sparsehash_equal_key> SHMap;
typedef google::dense_hash_map<VALUE, VALUE, sparsehash_hash, sparsehash_equal_key> DHMap;
typedef google::sparse_hash_set<VALUE, sparsehash_hash, sparsehash_equal_key> SHSet;
typedef google::dense_hash_set<VALUE, sparsehash_hash, sparsehash_equal_key> DHSet;
typedef std::map<VALUE, VALUE, stl_key_compare> STLMap;
typedef std::set<VALUE, stl_key_compare> STLSet;

#ifdef __GNUC__
typedef std::hash_map<VALUE, VALUE, sparsehash_hash, sparsehash_equal_key> GNUHashMap;
typedef std::hash_set<VALUE, sparsehash_hash, sparsehash_equal_key> GNUHashSet;
#endif

template <class T>
void sparsehash_initialize(T *x) {
};

template <>
void sparsehash_initialize<SHMap>(SHMap *x) {
  x->set_deleted_key(Qnil);
}

template <>
void sparsehash_initialize<SHSet>(SHSet *x) {
  x->set_deleted_key(Qnil);
}

template <>
void sparsehash_initialize<DHMap>(DHMap *x) {
  x->set_empty_key((VALUE) NULL);
  x->set_deleted_key(Qnil);
}

template <>
void sparsehash_initialize<DHSet>(DHSet *x) {
  x->set_empty_key((VALUE) NULL);
  x->set_deleted_key(Qnil);
}

template <class T>
void sparsehash_validate_key(VALUE &x) {
  if (TYPE(x) != T_STRING) {
    rb_raise(rb_eArgError, "Invalid key (String only)");
  }
}

template <class T>
struct SparsehashMap {
  T *m;

  static void mark(SparsehashMap<T> *p) {
    if (!p->m) {
      return;
    }

    T *m = p->m;

    for(typename T::iterator i = m->begin(); i != m->end(); i++) {
      rb_gc_mark(i->first);
      rb_gc_mark(i->second);
    }
  }

  static void free(SparsehashMap<T> *p) {
    if (p->m) {
      delete p->m;
    }

    delete p;
  }

  static VALUE alloc(VALUE klass) {
    SparsehashMap<T> *p;

    p = new SparsehashMap<T>;
    p->m = NULL;

    return Data_Wrap_Struct(klass, &mark, &free, p);
  }

  static VALUE initialize(VALUE self) {
    SparsehashMap<T> *p;

    Data_Get_Struct(self, SparsehashMap<T>, p);
    p->m = new T;
    sparsehash_initialize<T>(p->m);

    return Qnil;
  }

  static VALUE get(VALUE self, VALUE key) {
    SparsehashMap<T> *p;

    sparsehash_validate_key<T>(key);
    Data_Get_Struct(self, SparsehashMap<T>, p);
    T &m = *(p->m);

    VALUE value = m[key];

    return(value ? value : Qnil);
  }

  static VALUE set(VALUE self, VALUE key, VALUE value) {
    SparsehashMap<T> *p;

    sparsehash_validate_key<T>(key);
    Data_Get_Struct(self, SparsehashMap<T>, p);
    T &m = *(p->m);

    m[key] = value;

    return value;
  }

  static VALUE each0(VALUE args) {
    return rb_yield(args);
  }

  static VALUE each(VALUE self) {
    SparsehashMap<T> *p;

    rb_need_block();

    Data_Get_Struct(self, SparsehashMap<T>, p);
    T &m = *(p->m);
    int status = 0;

    for(typename T::iterator i = m.begin(); i != m.end(); i++) {
      VALUE args = rb_ary_new3(2, i->first, i->second);

      rb_protect(each0, args, &status);

      if (status != 0) {
        break;
      }
    }

    if (status != 0) {
      rb_jump_tag(status);
    }

    return self;
  }

  static VALUE erase(VALUE self, VALUE key) {
    SparsehashMap<T> *p;

    sparsehash_validate_key<T>(key);
    Data_Get_Struct(self, SparsehashMap<T>, p);
    T &m = *(p->m);

    VALUE value = m[key];
    m.erase(key);

    return(value ? value : Qnil);
  }

  static VALUE size(VALUE self) {
    SparsehashMap<T> *p;

    Data_Get_Struct(self, SparsehashMap<T>, p);
    T &m = *(p->m);

    return LONG2NUM(m.size());
  }

  static VALUE empty(VALUE self) {
    SparsehashMap<T> *p;

    Data_Get_Struct(self, SparsehashMap<T>, p);
    T &m = *(p->m);

    return m.empty() ? Qtrue : Qfalse;
  }

  static VALUE clear(VALUE self) {
    SparsehashMap<T> *p;

    Data_Get_Struct(self, SparsehashMap<T>, p);
    T &m = *(p->m);
    m.clear();

    return self;
  }

  static void init(VALUE &module, const char *name) {
    VALUE rb_cMap = rb_define_class_under(module, name, rb_cObject);

    rb_define_alloc_func(rb_cMap, &alloc);
    rb_include_module(rb_cMap, rb_mEnumerable);
    rb_define_private_method(rb_cMap, "initialize", __F(&initialize), 0);
    rb_define_method(rb_cMap, "[]", __F(&get), 1);
    rb_define_method(rb_cMap, "[]=", __F(&set), 2);
    rb_define_method(rb_cMap, "each", __F(&each), 0);
    rb_define_method(rb_cMap, "erase", __F(&erase), 1);
    rb_define_method(rb_cMap, "delete", __F(&erase), 1);
    rb_define_method(rb_cMap, "size", __F(&size), 0);
    rb_define_method(rb_cMap, "length", __F(&size), 0);
    rb_define_method(rb_cMap, "empty?", __F(&empty), 0);
    rb_define_method(rb_cMap, "clear", __F(&clear), 0);
  }
};

template <class T>
struct SparsehashSet {
  T *s;

  static void mark(SparsehashSet<T> *p) {
    if (!p->s) {
      return;
    }

    T *s = p->s;

    for(typename T::iterator i = s->begin(); i != s->end(); i++) {
      rb_gc_mark(*i);
    }
  }

  static void free(SparsehashSet<T> *p) {
    if (p->s) {
      delete p->s;
    }

    delete p;
  }

  static VALUE alloc(VALUE klass) {
    SparsehashSet<T> *p;

    p = new SparsehashSet<T>;
    p->s = NULL;

    return Data_Wrap_Struct(klass, &mark, &free, p);
  }

  static VALUE initialize(VALUE self) {
    SparsehashSet<T> *p;

    Data_Get_Struct(self, SparsehashSet<T>, p);
    p->s = new T;
    sparsehash_initialize<T>(p->s);

    return Qnil;
  }

  static VALUE insert(VALUE self, VALUE value) {
    SparsehashSet<T> *p;

    sparsehash_validate_key<T>(value);
    Data_Get_Struct(self, SparsehashSet<T>, p);
    T &s = *(p->s);
    s.insert(value);

    return self;
  }

  static VALUE each0(VALUE arg) {
    return rb_yield(arg);
  }

  static VALUE each(VALUE self) {
    SparsehashSet<T> *p;

    rb_need_block();

    Data_Get_Struct(self, SparsehashSet<T>, p);
    T &s = *(p->s);
    int status = 0;

    for(typename T::iterator i = s.begin(); i != s.end(); i++) {
      rb_protect(each0, *i, &status);

      if (status != 0) {
        break;
      }
    }

    return self;
  }

  static VALUE erase(VALUE self, VALUE value) {
    SparsehashSet<T> *p;

    sparsehash_validate_key<T>(value);
    Data_Get_Struct(self, SparsehashSet<T>, p);
    T &s = *(p->s);
    s.erase(value);

    return self;
  }

  static VALUE size(VALUE self) {
    SparsehashSet<T> *p;

    Data_Get_Struct(self, SparsehashSet<T>, p);
    T &s = *(p->s);

    return LONG2NUM(s.size());
  }

  static VALUE empty(VALUE self) {
    SparsehashSet<T> *p;

    Data_Get_Struct(self, SparsehashSet<T>, p);
    T &s = *(p->s);

    return s.empty() ? Qtrue : Qfalse;
  }

  static VALUE clear(VALUE self) {
    SparsehashSet<T> *p;

    Data_Get_Struct(self, SparsehashSet<T>, p);
    T &s = *(p->s);
    s.clear();

    return self;
  }

  static void init(VALUE &module, const char *name) {
    VALUE rb_cSet = rb_define_class_under(module, name, rb_cObject);

    rb_define_alloc_func(rb_cSet, &alloc);
    rb_include_module(rb_cSet, rb_mEnumerable);
    rb_define_private_method(rb_cSet, "initialize", __F(&initialize), 0);
    rb_define_method(rb_cSet, "insert", __F(&insert), 1);
    rb_define_method(rb_cSet, "<<", __F(&insert), 1);
    rb_define_method(rb_cSet, "each", __F(&each), 0);
    rb_define_method(rb_cSet, "erase", __F(&erase), 1);
    rb_define_method(rb_cSet, "delete", __F(&erase), 1);
    rb_define_method(rb_cSet, "size", __F(&size), 0);
    rb_define_method(rb_cSet, "length", __F(&size), 0);
    rb_define_method(rb_cSet, "empty?", __F(&empty), 0);
    rb_define_method(rb_cSet, "clear", __F(&clear), 0);
  }
};

} // namespace

void Init_sparsehash() {
  VALUE rb_mSparsehash = rb_define_module("Sparsehash");
  SparsehashMap<SHMap>::init(rb_mSparsehash, "SparseHashMap");
  SparsehashMap<DHMap>::init(rb_mSparsehash, "DenseHashMap");
  SparsehashSet<SHSet>::init(rb_mSparsehash, "SparseHashSet");
  SparsehashSet<DHSet>::init(rb_mSparsehash, "DenseHashSet");

  VALUE rb_mSTL = rb_define_module("STL");
  SparsehashMap<STLMap>::init(rb_mSTL, "Map");
  SparsehashSet<STLSet>::init(rb_mSTL, "Set");

#ifdef __GNUC__
  VALUE rb_mGNU = rb_define_module("GNU");
  SparsehashMap<GNUHashMap>::init(rb_mGNU, "HashMap");
  SparsehashSet<GNUHashSet>::init(rb_mGNU, "HashSet");
#endif
}
