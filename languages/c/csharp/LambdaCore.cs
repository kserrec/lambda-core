using System;

internal static class LambdaCore
{
    // A lambda-calculus term is a function from one term to another term.
    // The wrapper makes that recursive type expressible in C#.
    private sealed class Term
    {
        private readonly Func<Term, Term> function;

        public Term(Func<Term, Term> function)
        {
            this.function = function;
        }

        public Term Apply(Term argument)
        {
            return function(argument);
        }
    }

    private static Term Lambda(Func<Term, Term> function)
    {
        return new Term(function);
    }

    // TRUE = λx.λy.x
    private static Term ChurchTrue()
    {
        return Lambda(x => Lambda(_ => x));
    }

    // FALSE = λx.λy.y
    private static Term ChurchFalse()
    {
        return Lambda(_ => Lambda(y => y));
    }

    // NOT = λb.b FALSE TRUE
    private static Term ChurchNot()
    {
        return Lambda(boolean =>
            boolean.Apply(ChurchFalse()).Apply(ChurchTrue()));
    }

    // AND = λp.λq.p q FALSE
    private static Term ChurchAnd()
    {
        return Lambda(left => Lambda(right =>
            left.Apply(right).Apply(ChurchFalse())));
    }

    // OR = λp.λq.p TRUE q
    private static Term ChurchOr()
    {
        return Lambda(left => Lambda(right =>
            left.Apply(ChurchTrue()).Apply(right)));
    }

    // ZERO = λf.λx.x
    private static Term Zero()
    {
        return Lambda(_ => Lambda(value => value));
    }

    // SUCC = λn.λf.λx.f (n f x)
    private static Term Successor()
    {
        return Lambda(numeral => Lambda(function => Lambda(value =>
            function.Apply(numeral.Apply(function).Apply(value)))));
    }

    // PRED = λn.λf.λx.
    //          n (λg.λh.h (g f)) (λu.x) (λu.u)
    private static Term Predecessor()
    {
        return Lambda(numeral => Lambda(function => Lambda(value =>
            numeral
                .Apply(Lambda(g => Lambda(h =>
                    h.Apply(g.Apply(function)))))
                .Apply(Lambda(_ => value))
                .Apply(Lambda(term => term)))));
    }

    private static Term One()
    {
        return Successor().Apply(Zero());
    }

    // These observers only turn encoded results into printable C# values.
    // The encodings and their operations do not use C# bools or integers.
    private static bool ChurchToBool(Term boolean)
    {
        Term whenTrue = Lambda(term => term);
        Term whenFalse = Lambda(term => term);
        Term selected = boolean.Apply(whenTrue).Apply(whenFalse);

        if (object.ReferenceEquals(selected, whenTrue))
        {
            return true;
        }

        if (object.ReferenceEquals(selected, whenFalse))
        {
            return false;
        }

        throw new InvalidOperationException(
            "A Church boolean did not select either argument.");
    }

    private static int ChurchToInt(Term numeral)
    {
        int applications = 0;
        Term increment = Lambda(term =>
        {
            applications += 1;
            return term;
        });
        Term seed = Lambda(term => term);

        numeral.Apply(increment).Apply(seed);
        return applications;
    }

    private static void CheckBoolean(string label, Term boolean, bool expected)
    {
        bool actual = ChurchToBool(boolean);
        if (actual != expected)
        {
            throw new InvalidOperationException(
                $"{label}: expected {expected}, got {actual}.");
        }

        Console.WriteLine($"{label}: {actual.ToString().ToLowerInvariant()}");
    }

    private static void CheckNumeral(string label, Term numeral, int expected)
    {
        int actual = ChurchToInt(numeral);
        if (actual != expected)
        {
            throw new InvalidOperationException(
                $"{label}: expected {expected}, got {actual}.");
        }

        Console.WriteLine($"{label}: {actual}");
    }

    private static void Main()
    {
        Console.WriteLine("CHURCH BOOLEANS");
        CheckBoolean("TRUE", ChurchTrue(), true);
        CheckBoolean("FALSE", ChurchFalse(), false);
        CheckBoolean("NOT TRUE", ChurchNot().Apply(ChurchTrue()), false);
        CheckBoolean("NOT FALSE", ChurchNot().Apply(ChurchFalse()), true);
        CheckBoolean(
            "FALSE AND FALSE",
            ChurchAnd().Apply(ChurchFalse()).Apply(ChurchFalse()),
            false);
        CheckBoolean(
            "FALSE AND TRUE",
            ChurchAnd().Apply(ChurchFalse()).Apply(ChurchTrue()),
            false);
        CheckBoolean(
            "TRUE AND FALSE",
            ChurchAnd().Apply(ChurchTrue()).Apply(ChurchFalse()),
            false);
        CheckBoolean(
            "TRUE AND TRUE",
            ChurchAnd().Apply(ChurchTrue()).Apply(ChurchTrue()),
            true);
        CheckBoolean(
            "FALSE OR FALSE",
            ChurchOr().Apply(ChurchFalse()).Apply(ChurchFalse()),
            false);
        CheckBoolean(
            "FALSE OR TRUE",
            ChurchOr().Apply(ChurchFalse()).Apply(ChurchTrue()),
            true);
        CheckBoolean(
            "TRUE OR FALSE",
            ChurchOr().Apply(ChurchTrue()).Apply(ChurchFalse()),
            true);
        CheckBoolean(
            "TRUE OR TRUE",
            ChurchOr().Apply(ChurchTrue()).Apply(ChurchTrue()),
            true);

        Console.WriteLine("CHURCH NUMERALS");
        CheckNumeral("ZERO", Zero(), 0);
        CheckNumeral("ONE", One(), 1);
        CheckNumeral("SUCC ONE", Successor().Apply(One()), 2);
        CheckNumeral(
            "SUCC (SUCC ONE)",
            Successor().Apply(Successor().Apply(One())),
            3);
        CheckNumeral("PRED ZERO", Predecessor().Apply(Zero()), 0);
        CheckNumeral("PRED ONE", Predecessor().Apply(One()), 0);
        CheckNumeral(
            "PRED (SUCC ONE)",
            Predecessor().Apply(Successor().Apply(One())),
            1);
        CheckNumeral(
            "PRED (SUCC (SUCC ONE))",
            Predecessor().Apply(
                Successor().Apply(Successor().Apply(One()))),
            2);
    }
}
