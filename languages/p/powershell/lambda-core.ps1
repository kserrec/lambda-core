Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# TRUE = λx.λy.x
$ChurchTrue = {
    param([object] $X)

    $Selected = $X
    return { param([object] $_Y) $Selected }.GetNewClosure()
}

# FALSE = λx.λy.y
$ChurchFalse = {
    param([object] $_X)

    return { param([object] $Y) $Y }
}

# NOT = λb.b FALSE TRUE
$ChurchNot = {
    param([scriptblock] $Boolean)

    $WithFalse = & $Boolean $ChurchFalse
    return & $WithFalse $ChurchTrue
}.GetNewClosure()

# AND = λp.λq.p q FALSE
$ChurchAnd = {
    param([scriptblock] $Left)

    $CapturedLeft = $Left
    $CapturedFalse = $ChurchFalse
    return {
        param([scriptblock] $Right)

        $Selected = & $CapturedLeft $Right
        return & $Selected $CapturedFalse
    }.GetNewClosure()
}.GetNewClosure()

# OR = λp.λq.p TRUE q
$ChurchOr = {
    param([scriptblock] $Left)

    $CapturedLeft = $Left
    $CapturedTrue = $ChurchTrue
    return {
        param([scriptblock] $Right)

        $Selected = & $CapturedLeft $CapturedTrue
        return & $Selected $Right
    }.GetNewClosure()
}.GetNewClosure()

# ZERO = λf.λx.x
$Zero = {
    param([scriptblock] $_Function)

    return { param([object] $Value) $Value }
}

# SUCC = λn.λf.λx.f (n f x)
$Successor = {
    param([scriptblock] $Numeral)

    $CapturedNumeral = $Numeral
    return {
        param([scriptblock] $Function)

        $NumeralForValue = $CapturedNumeral
        $CapturedFunction = $Function
        return {
            param([object] $Value)

            $NumeralAtFunction = & $NumeralForValue $CapturedFunction
            $Inner = & $NumeralAtFunction $Value
            return & $CapturedFunction $Inner
        }.GetNewClosure()
    }.GetNewClosure()
}

# PRED = λn.λf.λx.n (λg.λh.h (g f)) (λu.x) (λa.a)
$Predecessor = {
    param([scriptblock] $Numeral)

    $CapturedNumeral = $Numeral
    return {
        param([scriptblock] $Function)

        $NumeralForValue = $CapturedNumeral
        $CapturedFunction = $Function
        return {
            param([object] $Value)

            $StepFunction = $CapturedFunction
            $Step = {
                param([scriptblock] $G)

                $CapturedG = $G
                $FunctionForG = $StepFunction
                return {
                    param([scriptblock] $H)

                    $GAtFunction = & $CapturedG $FunctionForG
                    return & $H $GAtFunction
                }.GetNewClosure()
            }.GetNewClosure()

            $SeedValue = $Value
            $Seed = { param([object] $_U) $SeedValue }.GetNewClosure()
            $Identity = { param([object] $Term) $Term }

            $AtStep = & $NumeralForValue $Step
            $AtSeed = & $AtStep $Seed
            return & $AtSeed $Identity
        }.GetNewClosure()
    }.GetNewClosure()
}

$One = & $Successor $Zero

# These observers are the only code that converts terms to native values.
function ConvertFrom-ChurchBoolean {
    param([scriptblock] $Boolean)

    $Selected = & $Boolean $true
    return [bool] (& $Selected $false)
}

function ConvertFrom-ChurchNumeral {
    param([scriptblock] $Numeral)

    $Increment = { param([int] $Value) $Value + 1 }
    $AtIncrement = & $Numeral $Increment
    return [int] (& $AtIncrement 0)
}

function Assert-ChurchBoolean {
    param(
        [string] $Label,
        [scriptblock] $Boolean,
        [bool] $Expected
    )

    $Actual = ConvertFrom-ChurchBoolean $Boolean
    if ($Actual -ne $Expected) {
        throw "$Label`: expected $Expected, got $Actual"
    }

    Write-Output ('{0}: {1}' -f $Label, $Actual.ToString().ToLowerInvariant())
}

function Assert-ChurchNumeral {
    param(
        [string] $Label,
        [scriptblock] $Numeral,
        [int] $Expected
    )

    $Actual = ConvertFrom-ChurchNumeral $Numeral
    if ($Actual -ne $Expected) {
        throw "$Label`: expected $Expected, got $Actual"
    }

    Write-Output ('{0}: {1}' -f $Label, $Actual)
}

Write-Output 'CHURCH BOOLEANS'
Assert-ChurchBoolean 'TRUE' $ChurchTrue $true
Assert-ChurchBoolean 'FALSE' $ChurchFalse $false
Assert-ChurchBoolean 'NOT TRUE' (& $ChurchNot $ChurchTrue) $false
Assert-ChurchBoolean 'NOT FALSE' (& $ChurchNot $ChurchFalse) $true
Assert-ChurchBoolean 'FALSE AND FALSE' (& (& $ChurchAnd $ChurchFalse) $ChurchFalse) $false
Assert-ChurchBoolean 'FALSE AND TRUE' (& (& $ChurchAnd $ChurchFalse) $ChurchTrue) $false
Assert-ChurchBoolean 'TRUE AND FALSE' (& (& $ChurchAnd $ChurchTrue) $ChurchFalse) $false
Assert-ChurchBoolean 'TRUE AND TRUE' (& (& $ChurchAnd $ChurchTrue) $ChurchTrue) $true
Assert-ChurchBoolean 'FALSE OR FALSE' (& (& $ChurchOr $ChurchFalse) $ChurchFalse) $false
Assert-ChurchBoolean 'FALSE OR TRUE' (& (& $ChurchOr $ChurchFalse) $ChurchTrue) $true
Assert-ChurchBoolean 'TRUE OR FALSE' (& (& $ChurchOr $ChurchTrue) $ChurchFalse) $true
Assert-ChurchBoolean 'TRUE OR TRUE' (& (& $ChurchOr $ChurchTrue) $ChurchTrue) $true

Write-Output 'CHURCH NUMERALS'
Assert-ChurchNumeral 'ZERO' $Zero 0
Assert-ChurchNumeral 'ONE' $One 1
Assert-ChurchNumeral 'SUCC ONE' (& $Successor $One) 2
Assert-ChurchNumeral 'SUCC (SUCC ONE)' (& $Successor (& $Successor $One)) 3
Assert-ChurchNumeral 'PRED ZERO' (& $Predecessor $Zero) 0
Assert-ChurchNumeral 'PRED ONE' (& $Predecessor $One) 0
Assert-ChurchNumeral 'PRED (SUCC ONE)' (& $Predecessor (& $Successor $One)) 1
Assert-ChurchNumeral 'PRED (SUCC (SUCC ONE))' (& $Predecessor (& $Successor (& $Successor $One))) 2
