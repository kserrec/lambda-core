// #define MEM_STATS

// #define SLOW

#define SLOW_SUMNAT
#define SLOW_FACTORIAL

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>

#ifdef MEM_STATS
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
#else
#define Malloc(s) calloc(1, s)
#define Free(p) free(p)
#endif

// ==================
// TYPES
// ==================

typedef uint8_t byte;

#define var(n) bind n = last++;
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

char *boolToStr(bool b) {
    if(b) return "true";
    else  return "false";
}

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

void replaceBinds(expr *subst, bind old, bind new) {
    if(false){}
    else if(subst->type == EXPR_BIND) {
        if(subst->bind == old) subst->bind = new;
    }
    else if(subst->type == EXPR_FUN) {
        replaceBinds(subst->body, old, new);
    }
    else if(subst->type == EXPR_APP) {
        replaceBinds(subst->lhs, old, new);
        replaceBinds(subst->rhs, old, new);
    }
}

void updateBinds(expr *subst) {
    if(false){}
    else if(subst->type == EXPR_FUN) {
        var(newBind);
        replaceBinds(subst->body, subst->arg, newBind);
        subst->arg = newBind;
        updateBinds(subst->body);
    }
    else if(subst->type == EXPR_APP) {
        updateBinds(subst->lhs);
        updateBinds(subst->rhs);
    }
}

expr substitute(expr body, bind b, expr subst) {
    if(false) {}
    else if(body.type == EXPR_BIND) {
        if(body.bind == b) {
            subst = cloneExprInPlace(&subst);
            updateBinds(&subst);
            return subst;
        }
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

void printExpr(expr e);
expr evaluate(expr f) {
    f = cloneExprInPlace(&f);
    bool doneWork;
    do {
        // printExpr(f);
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
        printf("[%d]", e.bind);
        // printf("%c", getVarName(e.bind, lastTaken, binds, vars));
    }
    else if(e.type == EXPR_FUN) {
        printf("λ[%d]", e.arg);
        // printf("( λ%c.", getVarName(e.arg, lastTaken, binds, vars));
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
    { \
        var(b); \
        { \
            expr __ftemp; \
            { \
                expr temp = body; \
                    __ftemp = mkFun(&temp); \
            } \
            temp = __ftemp; \
        } \
        temp.arg = b; \
    }

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
    } \
    fname = evaluate(fname);

#define DefunLazy(fname, b, body) \
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
    } \

#define Defvar(vname, body) \
    expr vname; \
    { \
        expr temp = body; \
        vname = temp; \
    } \
    vname = evaluate(vname);

#define DefunImpure(fname, argty, argname, body) \
    expr __##fname(byte *__##argname, size_t len) { \
        assert(len == sizeof(argty)); \
        argty argname = *(argty *)__##argname; \
        body; \
        __##argname = Malloc(sizeof(argty)); \
        *__##argname = argname; \
        return (expr){ .type = EXPR_IMPURE_VAL, .valp = __##argname, .vall = sizeof(argty) }; \
    } \
    expr fname = (expr){ .type = EXPR_IMPURE_FUN, .fun = __##fname }; \

#define DefvarImpure(vname, vty, vval) \
    vty *__##vname = Malloc(sizeof(vty)); \
    *__##vname = vval; \
    expr vname = (expr){ .type = EXPR_IMPURE_VAL, .valp = (byte *)__##vname, .vall = sizeof(vty) }; \

#define ReadVarImpure(var, ty) *(ty *)var.valp
        
// ==================
// USAGE
// ==================

expr __ImpureIdentity(byte *ptr, size_t len) {
    byte *ret = Malloc(len);
    memcpy(ret, ptr, len);
    return (expr){ .type = EXPR_IMPURE_VAL, .valp = ret, .vall = len };
}

DefunImpure(ImpureIncrement, uint64_t, num, {
    num++;
});

int main() {

    // Zero and Successor
    Defun(Zero, s, Fun(z, Bind(z)));
    Defun(Succ, w, Fun(y, Fun(x, App(Bind(y), App(App(Bind(w), Bind(y)), Bind(x))))));

    // Simple numbers
    Defvar(One, App(Succ, Zero));
    Defvar(Two, App(Succ, One));
    Defvar(Three, App(Succ, App(Succ, App(Succ, Zero))));
    Defvar(Four, App(Succ, Three));

    // Sum and Multiplication
    Defun(Sum, x, Fun(y, App(App(Bind(x), Succ), Bind(y))));
    Defun(Mul, x, Fun(y, Fun(z, App(Bind(x), App(Bind(y), Bind(z))))));

    // More complicated numbers
    Defvar(Five, App(App(Sum, Two), Three));
    Defvar(Six, App(App(Sum, Three), Three));
    Defvar(Twelve, App(App(Mul, Three), Four));
    Defvar(Twenty, App(App(Mul, Five), Four));

    // Booleans
    Defun(True, x, Fun(y, Bind(x)));
    Defun(False, x, Fun(y, Bind(y)));

    // Boolean operations
    Defun(And, x, Fun(y, App(App(Bind(x), Bind(y)), False)));
    Defun(Or, x, Fun(y, App(App(Bind(x), True), Bind(y))));
    Defun(Not, x, App(App(Bind(x), False), True));

    Defun(IsZero, x, App(App(App(Bind(x), False), Not), False));

    Defvar(ZeroIsZero, App(IsZero, Zero));
    Defvar(TwoIsZero, App(IsZero, Two));

    // Boolean operations examples
    Defvar(BothZeroAndTwoAreZero, App(App(And, ZeroIsZero), TwoIsZero));
    Defvar(EitherZeroOrTwoIsZero, App(App(Or, ZeroIsZero), TwoIsZero));

    // Predecessor
    Defun(PredAux, p, Fun(z, App(App(Bind(z), App(Succ, App(Bind(p), True))), App(Bind(p), True))));
    Defun(Pred, n, App(App(App(Bind(n), PredAux), Fun(z, App(App(Bind(z), Zero), Zero))), False));

    // Predecessor example
    Defvar(Eleven, App(Pred, Twelve));

    // Comparison
    Defun(IsGreaterOrEqual, x, Fun(y, App(IsZero, App(App(Bind(x), Pred), Bind(y)))));
    Defun(IsLess, x, Fun(y, App(Not, App(App(IsGreaterOrEqual, Bind(x)), Bind(y)))));
    Defun(IsEqual, x, Fun(y, App(App(And, App(App(IsGreaterOrEqual, Bind(x)), Bind(y))), App(App(IsGreaterOrEqual, Bind(y)), Bind(x)))));
    Defun(IsLessOrEqual, x, Fun(y, App(App(Or, App(App(IsLess, Bind(x)), Bind(y))), App(App(IsEqual, Bind(x)), Bind(y)))));
    Defun(IsGreater, x, Fun(y, App(App(And, App(App(IsGreaterOrEqual, Bind(x)), Bind(y))), App(Not, App(App(IsEqual, Bind(x)), Bind(y))))));

    // Comparison examples
    Defvar(FiveGThree, App(App(IsGreater, Five), Three));
    Defvar(TwoGThree, App(App(IsGreater, Two), Three));
    Defvar(TwoLEFive, App(App(IsLessOrEqual, Two), Five));
    Defvar(FiveLEFive, App(App(IsLessOrEqual, Five), Five));

    // Recursive Y and Z combinators
    DefunLazy(YC, y, App(Fun(x, App(Bind(y), App(Bind(x), Bind(x)))), Fun(x, App(Bind(y), App(Bind(x), Bind(x))))));
    DefunLazy(ZC, f, App(Fun(x, App(Bind(f), Fun(v, App(App(Bind(x), Bind(x)), Bind(v))))), Fun(x, App(Bind(f), Fun(v, App(App(Bind(x), Bind(x)), Bind(v)))))));

    // Sum via Y combinator
    Defun(SumNatAux, r, Fun(n, App(App(App(IsZero, Bind(n)), Zero), App(App(Bind(n), Succ), App(Bind(r), App(Pred, Bind(n)))))));
    DefunLazy(SumNat, n, App(App(YC, SumNatAux), Bind(n)));
#if defined(SLOW) && defined(SLOW_SUMNAT)
    Defvar(SumTwelve, App(SumNat, Twelve));
#endif

    // Factorial via Y combinator
    Defun(FactAux, f, Fun(n, App(App(App(IsZero, Bind(n)), One), App(App(Mul, Bind(n)), App(Bind(f), App(Pred, Bind(n)))))));
    DefunLazy(Fact, n, App(App(YC, FactAux), Bind(n)));
#if defined(SLOW) && defined(SLOW_FACTORIAL)
    Defvar(FactFive, App(Fact, Five));
#endif

    // Defining impure values for confirming results
    DefvarImpure(ImpureZero, uint64_t, 0);
    DefvarImpure(ImpureOne, uint64_t, 1);
    Defvar(ImpureFalse, ImpureZero);
    Defvar(ImpureTrue, ImpureOne);

    // Tests
    Defun(CheckNumber, n, App(App(Bind(n), ImpureIncrement), ImpureZero));
    Defun(CheckBool, b, App(App(Bind(b), ImpureTrue), ImpureFalse));

    Defvar(CheckTwenty, App(CheckNumber, Twenty));
    printf("Twenty evaluates to: %d\n", ReadVarImpure(CheckTwenty, uint64_t));
    
    Defvar(CheckFour, App(CheckNumber, Four));
    printf("Four evaluates to: %d\n", ReadVarImpure(CheckFour, uint64_t));

    Defvar(CheckEleven, App(CheckNumber, Eleven));
    printf("Eleven evaluates to: %d\n", ReadVarImpure(CheckEleven, uint64_t));

    Defvar(CheckZeroIsZero, App(CheckBool, ZeroIsZero));
    printf("isZero(0) evaluates to: %s\n", boolToStr(ReadVarImpure(CheckZeroIsZero, bool)));

    Defvar(CheckTwoIsZero, App(CheckBool, TwoIsZero));
    printf("isZero(2) evaluates to: %s\n", boolToStr(ReadVarImpure(CheckTwoIsZero, bool)));

    Defvar(CheckBothZeroAndTwoAreZero, App(CheckBool, BothZeroAndTwoAreZero));
    printf("isZero(0) && isZero(2) evaluates to: %s\n", boolToStr(ReadVarImpure(CheckBothZeroAndTwoAreZero, bool)));

    Defvar(CheckEitherZeroOrTwoIsZero, App(CheckBool, EitherZeroOrTwoIsZero));
    printf("isZero(0) || isZero(2) evaluates to: %s\n", boolToStr(ReadVarImpure(CheckEitherZeroOrTwoIsZero, bool)));

    Defvar(CheckFiveGThree, App(CheckBool, FiveGThree));
    printf("5 > 3 evaluates to: %s\n", boolToStr(ReadVarImpure(CheckFiveGThree, bool)));

    Defvar(CheckTwoGThree,  App(CheckBool, TwoGThree));
    printf("2 > 3 evaluates to: %s\n", boolToStr(ReadVarImpure(CheckTwoGThree, bool)));

    Defvar(CheckTwoLEFive,  App(CheckBool, TwoLEFive));
    printf("2 <= 5 evaluates to: %s\n", boolToStr(ReadVarImpure(CheckTwoLEFive, bool)));

    Defvar(CheckFiveLEFive, App(CheckBool, FiveLEFive));
    printf("5 <= 5 evaluates to: %s\n", boolToStr(ReadVarImpure(CheckFiveLEFive, bool)));

#if defined(SLOW) && defined(SLOW_SUMNAT)
    Defvar(CheckSumTwelve, App(CheckNumber, SumTwelve));
    printf("Sum of all numbers up to twelve evaluates to: %d\n", ReadVarImpure(CheckSumTwelve, uint64_t));
#endif

#if defined(SLOW) && defined(SLOW_FACTORIAL)
    Defvar(CheckFactFive, App(CheckNumber, FactFive));
    printf("Five factorial evaluates to: %d\n", ReadVarImpure(CheckFactFive, uint64_t));
#endif

#ifdef MEM_STATS
    printf("MALLOC: %d; FREE: %d; FINAL: %d; PEAK: %d\n", mallocCount, freeCount, finalCount, peakCount);
#endif

    return 0;
}
