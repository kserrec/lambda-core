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
            *(ret->valp) = *(e->valp);
        }
    }
    else if(e->type == EXPR_IMPURE_FUN) {
        ret->fun = e->fun;
    }

    return ret;
}

expr cloneExprInPlace(expr *e) {
    expr *retp = cloneExpr(e);
    expr ret = *retp;
    free(retp);
    return ret;
}

expr substitute(expr body, bind b, expr subst) {
    if(false) {}
    else if(body.type == EXPR_BIND) {
        if(body.bind == b)  return cloneExprInPlace(&subst);
        else                return body;  
    }
    else if(body.type == EXPR_FUN) {
        *body.body = substitute(*body.body, b, subst);
        return body;
    }
    else if(body.type == EXPR_APP) {
        *body.lhs = substitute(*body.lhs, b, subst);
        *body.rhs = substitute(*body.rhs, b, subst);
        return body;
    }
    else if(body.type == EXPR_IMPURE_VAL) {
        return body;
    }
    else if(body.type == EXPR_IMPURE_FUN) {
        return body;
    }
}

expr mkFun(expr *body) {
    expr fun = { .type = EXPR_FUN, .arg = 0, .body = cloneExpr(body) };
    return fun;
}

expr apply(expr f, expr e) {
    assert(f.type == EXPR_FUN || (f.type == EXPR_IMPURE_FUN && e.type == EXPR_IMPURE_VAL));

    if(f.type == EXPR_FUN) {
        return substitute(*f.body, f.arg, e);
    }
    else {
        return f.fun(e.valp, e.vall);
    }
}

expr _evaluate(expr f, bool *doneWork) {
    if(false) {}
    else if(f.type == EXPR_BIND) {
        return f;
    }
    else if(f.type == EXPR_FUN) {
        *f.body = _evaluate(*f.body, doneWork);
        return f;
    }
    else if(f.type == EXPR_APP) {
        expr lhs = _evaluate(*f.lhs, doneWork);
        expr rhs = _evaluate(*f.rhs, doneWork);
        f.lhs = cloneExpr(&lhs);
        f.rhs = cloneExpr(&rhs);
        while(f.type == EXPR_APP && (f.lhs->type == EXPR_FUN || (f.lhs->type == EXPR_IMPURE_FUN && f.rhs->type == EXPR_IMPURE_VAL))) {
            *doneWork = true;
            f = apply(*f.lhs, *f.rhs);
        }
        return f;
    }

    return f;
}

expr evaluate(expr f) {
    bool doneWork;
    do {
        doneWork = false;
        f = _evaluate(f, &doneWork);
    } while(doneWork);
    return f;
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

#define Defvar(vname, body) \
    expr vname; \
    { \
        expr temp = body; \
        vname = temp; \
    }

char getVarName(bind b, size_t *lastTaken, bind binds[], char vars[]) {
    for(int i = 0; i < *lastTaken; i++) {
        if(binds[i] == b) return vars[i];
    }

    binds[*lastTaken] = b;
    (*lastTaken)++;
    return vars[*lastTaken - 1];
}

void _printExpr(expr e, size_t *lastTaken, bind binds[], char vars[], bool isRhs) {
    if(false) {}
    else if(e.type == EXPR_BIND) {
        printf("%c", getVarName(e.bind, lastTaken, binds, vars));
    }
    else if(e.type == EXPR_FUN) {
        printf("( λ%c.", getVarName(e.arg, lastTaken, binds, vars));
        _printExpr(*e.body, lastTaken, binds, vars, false);
        printf(" )");
    }
    else if(e.type == EXPR_APP) {
        if(isRhs) printf("(");
        _printExpr(*e.lhs, lastTaken, binds, vars, false);
        _printExpr(*e.rhs, lastTaken, binds, vars, true);
        if(isRhs) printf(")");
    }
    else if(e.type == EXPR_IMPURE_VAL) {
        printf("[%d bytes]", e.vall);
    }
    else if(e.type == EXPR_IMPURE_FUN) {
        printf("<fun>");
    }
}

void printExpr(expr e) {
    bind binds[52] = {0};
    char vars[52] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    size_t lastTaken = 0;
    _printExpr(e, &lastTaken, binds, vars, false);
    printf("\n");
}

expr impure_increment(byte *data, size_t len) {
    assert(len == sizeof(uint64_t));
    uint64_t *ptr = (uint64_t *)data;
    uint64_t value = *ptr;
    value++;

    ptr = malloc(sizeof(uint64_t));
    *ptr = value;

    return (expr){ .type = EXPR_IMPURE_VAL, .valp = (byte *)ptr, .vall = sizeof(uint64_t) };
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

    Defun(Zero, s, Fun(z, Bind(z)));
    Defun(Succ, w, Fun(y, Fun(x, App(Bind(y), App(App(Bind(w), Bind(y)), Bind(x))))));

    Defvar(One, App(Succ, Zero));
    Defvar(Two, App(Succ, One));
    Defvar(Three, App(Succ, App(Succ, App(Succ, Zero))));

    uint64_t *number = malloc(sizeof(uint64_t));
    *number = 0;
    expr numberExpr = (expr){ .type = EXPR_IMPURE_VAL, .valp = (byte *)number, .vall = sizeof(uint64_t) };
    expr inc = (expr){ .type = EXPR_IMPURE_FUN, .fun = impure_increment };

    Defvar(CheckThree, App(App(Three, inc), numberExpr));

    expr checkThree = evaluate(CheckThree);
    assert(checkThree.type == EXPR_IMPURE_VAL);

    printExpr(CheckThree);
    printExpr(checkThree);
    
    printf("Three evaluates to: %d\n", *(uint64_t *)checkThree.valp);
}
