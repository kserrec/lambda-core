#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>

int64_t finalCount;
int64_t peakCount;
int64_t mallocCount;
int64_t freeCount;

void *Malloc(size_t size) {
    mallocCount++;
    finalCount++;
    if(finalCount > peakCount) peakCount = finalCount;

    return calloc(1, size);
}

void Free(void *ptr) {
    if(ptr == 0) return;
    freeCount++;
    finalCount--;

    free(ptr);
}

// ==================
// TYPES
// ==================

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

// ==================
// UTILITY
// ==================

void freeExpr(expr *e);

void freeExprInPlace(expr e) {
    if(false) {}
    else if(e.type == EXPR_FUN) { freeExpr(e.body); }
    else if(e.type == EXPR_APP) { freeExpr(e.lhs); freeExpr(e.rhs); }
    else if(e.type == EXPR_IMPURE_VAL) { Free(e.valp); }
}

void freeExpr(expr *e) {
    freeExprInPlace(*e);
    Free(e);
}

expr *cloneExpr(expr *e) {
    expr *ret = Malloc(sizeof(expr));
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
        ret->valp = Malloc(e->vall);
        memcpy(ret->valp, e->valp, e->vall);
    }
    else if(e->type == EXPR_IMPURE_FUN) {
        ret->fun = e->fun;
    }

    return ret;
}

expr cloneExprInPlace(expr *e) {
    expr *retp = cloneExpr(e);
    expr ret = *retp;
    Free(retp);
    return ret;
}

expr mkFun(expr *body) {
    expr fun = { .type = EXPR_FUN, .arg = 0, .body = cloneExpr(body) };
    return fun;
}

// ==================
// EVALUATING
// ==================

expr substitute(expr body, bind b, expr subst) {
    if(false) {}
    else if(body.type == EXPR_BIND) {
        if(body.bind == b)  return cloneExprInPlace(&subst);
        else                return cloneExprInPlace(&body);
    }
    else if(body.type == EXPR_FUN) {
        expr newBody = substitute(*body.body, b, subst);
        body.body = cloneExpr(&newBody);
        freeExprInPlace(newBody);

        return body;
    }
    else if(body.type == EXPR_APP) {
        expr newLhs = substitute(*body.lhs, b, subst);
        expr newRhs = substitute(*body.rhs, b, subst);
        body.lhs = cloneExpr(&newLhs);
        body.rhs = cloneExpr(&newRhs);
        freeExprInPlace(newLhs);
        freeExprInPlace(newRhs);

        return body;
    }
    else if(body.type == EXPR_IMPURE_VAL) {
        return cloneExprInPlace(&body);
    }
    else if(body.type == EXPR_IMPURE_FUN) {
        return cloneExprInPlace(&body);
    }
}

expr apply(expr f, expr e) {
    assert(f.type == EXPR_FUN || (f.type == EXPR_IMPURE_FUN && e.type == EXPR_IMPURE_VAL));

    if(f.type == EXPR_FUN) {
        expr result = substitute(*f.body, f.arg, e);
        return result;
    }
    else {
        expr result = f.fun(e.valp, e.vall);
        return result;
    }
}

expr _evaluate(expr f, bool *doneWork) {
    if(false) {}
    else if(f.type == EXPR_FUN) {
        expr newBody = _evaluate(*f.body, doneWork);
        f.body = cloneExpr(&newBody);
        freeExprInPlace(newBody);

        return f;
    }
    else if(f.type == EXPR_APP) {
        expr nlhs = _evaluate(*f.lhs, doneWork);
        expr nrhs = _evaluate(*f.rhs, doneWork);
        f.lhs = cloneExpr(&nlhs);
        f.rhs = cloneExpr(&nrhs);
        freeExprInPlace(nlhs);
        freeExprInPlace(nrhs);

        while(f.type == EXPR_APP && (f.lhs->type == EXPR_FUN || (f.lhs->type == EXPR_IMPURE_FUN && f.rhs->type == EXPR_IMPURE_VAL))) {

            *doneWork = true;

            expr toFree = f;
            f = apply(*f.lhs, *f.rhs);
            freeExprInPlace(toFree);
        }

        return f;
    }
    else {
        return cloneExprInPlace(&f);
    }
}

expr evaluate(expr f) {
    f = cloneExprInPlace(&f);
    bool doneWork;
    do {
        doneWork = false;
        expr nf = _evaluate(f, &doneWork);
        if(doneWork) { 
            freeExprInPlace(f);
            f = nf;
        }
        else {
            freeExprInPlace(nf);
        }
    } while(doneWork);
    return f;
}

// ==================
// PRINTING
// ==================

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

// ==================
// MACROS
// ==================

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

#define DefunImpure(fname, argty, argname, body) \
    expr __##fname(byte *__##argname, size_t len) { \
        assert(len == sizeof(argty)); \
        argty argname = *(argty *)__##argname; \
        body; \
        __##argname = Malloc(sizeof(argty)); \
        *__##argname = argname; \
        return (expr){ .type = EXPR_IMPURE_VAL, .valp = __##argname, .vall = sizeof(argty) }; \
    } \
    expr fname = (expr){ .type = EXPR_IMPURE_FUN, .fun = __##fname };

#define DefvarImpure(vname, vty, vval) \
    vty *__##vname = Malloc(sizeof(vty)); \
    *__##vname = vval; \
    expr vname = (expr){ .type = EXPR_IMPURE_VAL, .valp = (byte *)__##vname, .vall = sizeof(vty) }; \

#define ReadVarImpure(var, ty) *(ty *)var.valp

        
// ==================
// USAGE
// ==================

DefunImpure(ImpureIncrement, uint64_t, num, {
    num++;
});

int main() {

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

    DefvarImpure(ImpureZero, uint64_t, 0);
    Defvar(CheckThree, App(App(Three, ImpureIncrement), ImpureZero));

    expr checkThree = evaluate(CheckThree);
    assert(checkThree.type == EXPR_IMPURE_VAL);

    printExpr(CheckThree);
    printExpr(checkThree);
    
    evaluate(One);

    printf("Three evaluates to: %d\n", ReadVarImpure(checkThree, uint64_t));

    freeExprInPlace(True);
    freeExprInPlace(False);
    freeExprInPlace(Not);
    freeExprInPlace(And);
    freeExprInPlace(Or);
    freeExprInPlace(Zero);
    freeExprInPlace(Succ);
    freeExprInPlace(One);
    freeExprInPlace(Two);
    freeExprInPlace(Three);
    freeExprInPlace(CheckThree);
    freeExprInPlace(checkThree);

    printf("MALLOC: %d; FREE: %d; FINAL: %d; PEAK: %d\n", mallocCount, freeCount, finalCount, peakCount);
}
