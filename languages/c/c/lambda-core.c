#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <stdbool.h>

typedef uint8_t byte;

typedef uint64_t bind;
bind last;

typedef uint8_t expr_type;
#define EXPR_BIND 0
#define EXPR_FUN 1
#define EXPR_APP 2

#define EXPR_IMPURE_VAL 3
#define EXPR_IMPURE_FUN 4

typedef struct expr expr;
struct expr {
    expr_type type;
    union {
        struct {
            bind bind;
        };

        struct {
            bind arg;
            expr *body;
        };

        struct {
            expr *lhs;
            expr *rhs;
        };

        struct {
            byte *valp;
            size_t vall;
        };

        struct {
            expr (*fun)(byte* valp, size_t vall);
        };
    };
};

expr *cloneExpr(expr *e) {
    expr *ret = malloc(sizeof(expr));

    ret->type = e->type;

    if(false) {}
    else if(e->type == EXPR_BIND) {
        ret->bind = e->bind;
    }
    else if(e->type == EXPR_FUN) {
        ret->arg = e->arg;
        ret->body = cloneExpr(e->body);
    } 
    else if(e->type == EXPR_APP) {
        ret->lhs = cloneExpr(e->lhs);
        ret->rhs = cloneExpr(e->rhs);
    }
    else if(e->type == EXPR_IMPURE_VAL) {
        ret->vall = e->vall;
        ret->valp = malloc(e->vall);
        for(int i = 0; e->valp && i < e->vall; i++) {
            *ret->valp = *e->valp;
        }
    }
    else if(e->type == EXPR_IMPURE_FUN) {
        ret->fun = e->fun;
    }

    return ret;
}

expr substitute(expr body, bind b, expr e) {
    if(false) {}
    else if(body.type == EXPR_BIND) {
        if(body.bind == b) return e;
        else            return body;  
    }
    else if(body.type == EXPR_FUN) {
        *body.body = substitute(*body.body, b, e);
        return body;
    }
    else if(body.type == EXPR_APP) {
        *body.lhs = substitute(*body.lhs, b, e);
        *body.rhs = substitute(*body.rhs, b, e);
        return body;
    }
}

expr mkFun(expr *body) {
    expr fun = { .type = EXPR_FUN, .arg = 0, .body = cloneExpr(body) };
    return fun;
}

expr apply(expr f, expr e) {
    assert(f.type == EXPR_FUN);
    return substitute(*f.body, f.arg, e);
}

#define var(n) bind n = last++;

#define Bind(bi) (expr){ .type = EXPR_BIND, .bind = (bi) };

#define App(l, r) \
    {0}; \
    expr _temp; \
    { \
        expr __temp = (expr){ .type = EXPR_APP }; \
        { \
            expr temp = l; \
            __temp.lhs = cloneExpr(&temp); \
        } \
        { \
            expr temp = r; \
            __temp.rhs = cloneExpr(&temp); \
        } \
        _temp = __temp; \
    } \
    temp = _temp;

#define Fun(b, body) \
    {0}; \
    var(b); \
    { \
        expr __ftemp; \
        { \
            expr temp = body; \
            __ftemp = mkFun(&temp); \
        } \
        temp = __ftemp; \
    } \
    temp.arg = b;

#define Defun(fname, b, body) \
    expr fname; \
    { \
        var(b); \
        expr __ftemp; \
        { \
            expr temp = body; \
            __ftemp = mkFun(&temp); \
        } \
        __ftemp.arg = b; \
        fname = __ftemp; \
    }

int main() {

    /*
       testFunc = \a . (\a . a) a
    */

    Defun(testFunc, a,
        App(
            Fun(a, Bind(a)),
            Bind(a)
        )
    );

    Defun(True, x, Fun(y, Bind(x)));
    Defun(False, x, Fun(y, Bind(y)));

    Defun(Not, v, App(App(Bind(v), False), True));

    Defun(And, a, Fun(b, App(App(Bind(a), Bind(b)), False)));
    Defun(Or, a, Fun(b, App(App(Bind(a), True), Bind(b))));

    expr test = apply(Not, True);

    Defun(Zero, s, Fun(z, Bind(z)));
    Defun(Succ, w, Fun(y, Fun(x, App(Bind(y), App(App(Bind(w), Bind(y)), Bind(x))))));
}
