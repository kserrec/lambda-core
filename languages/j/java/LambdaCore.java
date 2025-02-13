import java.util.function.Function;

public interface LambdaCore {

    interface Bool extends Function<Bool, Function<Bool, Bool>> {
    }

    interface UnaryBoolOp extends Function<Bool, Bool> {
    }

    interface BinaryBoolOp extends Function<Bool, Function<Bool, Bool>> {
    }

    interface ChurchNumeral extends Function<Function<Integer, Integer>, Function<Integer, Integer>> {
    }

    Bool TRUE = x -> y -> x;
    Bool FALSE = x -> y -> y;

    UnaryBoolOp NOT = b -> b.apply(FALSE).apply(TRUE);
    BinaryBoolOp AND = b1 -> b2 -> b1.apply(b2).apply(FALSE);
    BinaryBoolOp OR = b1 -> b2 -> b1.apply(TRUE).apply(b2);

    ChurchNumeral ZERO = x -> y -> y;
    Function<ChurchNumeral, ChurchNumeral> SUCC = w -> y -> x -> y.apply(w.apply(y).apply(x));

//    Function<ChurchNumeral, ChurchNumeral> PRED = n -> f -> x ->
//            n.apply(g -> h -> h.apply(g.apply(f)))
//                    .apply(u -> x)
//                    .apply(u -> u);

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
        printChurchNumeral(SUCC.apply(ZERO));           // 1
    }

    static void printBool(Bool b) {
        if (b == TRUE)
            System.out.println("BOOLEAN TRUE");
        else if (b == FALSE)
            System.out.println("BOOLEAN FALSE");
        else
            throw new IllegalStateException();
    }

    static void printChurchNumeral(ChurchNumeral n) {
        System.out.println(n.apply(x -> x + 1).apply(0));
    }
}
