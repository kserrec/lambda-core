import java.util.function.Function;

public interface LambdaCore {

    interface Bool extends Function<Bool, Function<Bool, Bool>> {
    }

    interface UnaryBoolOp extends Function<Bool, Bool> {
    }

    interface BinaryBoolOp extends Function<Bool, Function<Bool, Bool>> {
    }

    // PRED applies a numeral to functions over functions, so numerals cannot be
    // pinned to Function<Integer, Integer>. Term is the untyped lambda calculus'
    // single universal type: everything is a function from Term to Term.
    interface Term extends Function<Term, Term> {
    }

    Bool TRUE = x -> y -> x;
    Bool FALSE = x -> y -> y;

    UnaryBoolOp NOT = b -> b.apply(FALSE).apply(TRUE);
    BinaryBoolOp AND = b1 -> b2 -> b1.apply(b2).apply(FALSE);
    BinaryBoolOp OR = b1 -> b2 -> b1.apply(TRUE).apply(b2);

    Term ZERO = f -> x -> x;
    Term SUCC = n -> f -> x -> f.apply(n.apply(f).apply(x));
    Term PRED = n -> f -> x ->
            n.apply(g -> h -> h.apply(g.apply(f)))
                    .apply(u -> x)
                    .apply(u -> u);
    Term ONE = SUCC.apply(ZERO);

    static void main(String[] args) {
        printBool(TRUE);                                // TRUE
        printBool(FALSE);                               // FALSE

        printBool(NOT.apply(TRUE));                     // FALSE
        printBool(NOT.apply(FALSE));                    // TRUE

        printBool(AND.apply(FALSE).apply(FALSE));       // FALSE
        printBool(AND.apply(TRUE).apply(FALSE));        // FALSE
        printBool(AND.apply(FALSE).apply(TRUE));        // FALSE
        printBool(AND.apply(TRUE).apply(TRUE));         // TRUE

        printBool(OR.apply(FALSE).apply(FALSE));        // FALSE
        printBool(OR.apply(TRUE).apply(FALSE));         // TRUE
        printBool(OR.apply(FALSE).apply(TRUE));         // TRUE
        printBool(OR.apply(TRUE).apply(TRUE));          // TRUE

        printChurchNumeral(ZERO);                       // 0
        printChurchNumeral(ONE);                        // 1
        printChurchNumeral(SUCC.apply(ONE));            // 2
        printChurchNumeral(PRED.apply(SUCC.apply(ONE))); // 1
        printChurchNumeral(PRED.apply(ONE));            // 0
        printChurchNumeral(PRED.apply(ZERO));           // 0
    }

    static void printBool(Bool b) {
        if (b == TRUE)
            System.out.println("BOOLEAN TRUE");
        else if (b == FALSE)
            System.out.println("BOOLEAN FALSE");
        else
            throw new IllegalStateException();
    }

    static void printChurchNumeral(Term n) {
        int[] count = {0};
        Term inc = t -> {
            count[0]++;
            return t;
        };
        n.apply(inc).apply(t -> t);
        System.out.println(count[0]);
    }
}
