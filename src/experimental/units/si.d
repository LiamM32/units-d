/**
 * International System of Units (SI) units and prefixes for use with
 * $(D std.units).
 *
 * The definitions have been taken from the NIST Special Publication 330,
 * $(WEB http://physics.nist.gov/Pubs/SP330/sp330.pdf, The International
 * System of Units), 2008 edition.
 *
 * Todo: $(UL
 *  $(LI Do something about the derived unit types being expanded in the
 *   generated documentation.)
 * )
 *
 * License: $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: $(WEB klickverbot.at, David Nadlinger)
 */
module experimental.units.si;

import experimental.units;

/**
 * The full $(XREF units, PrefixSystem) of SI prefixes.
 *
 * For each prefix, a helper template like $(D kilo!()) for prefixing units
 * is provided (see $(XREF units, prefixTemplate)).
 */
alias SiPrefixSystem = PrefixSystem!(10, {
        return [Prefix(-24, "yocto", "y"),
                Prefix(-21, "zepto", "z"),
                Prefix(-18, "atto", "a"),
                Prefix(-15, "femto", "f"),
                Prefix(-12, "pico", "p"),
                Prefix(-9, "nano", "n"),
                Prefix(-6, "micro", "µ"),
                Prefix(-3, "milli", "m"),
                Prefix(-2, "centi", "c"),
                Prefix(-1, "deci", "d"),
                Prefix(1, "deka", "da"),
                Prefix(2, "hecto", "h"),
                Prefix(3, "kilo", "k"),
                Prefix(6, "mega", "M"),
                Prefix(9, "giga", "G"),
                Prefix(12, "tera", "T"),
                Prefix(15, "peta", "P"),
                Prefix(18, "exa", "E"),
                Prefix(21, "zetta", "Z"),
                Prefix(24, "yotta", "Y")];
});

// TODO Add binary byte units

mixin DefinePrefixSystem!(SiPrefixSystem);

/**
 * SI base units.
 */
alias Ampere = BaseUnit!("Ampere", "A");
alias Candela = BaseUnit!("candela", "cd");
alias Gram = BaseUnit!("gram", "g");
alias Kelvin = BaseUnit!("Kelvin", "K");
alias Metre = BaseUnit!("metre", "m");
alias Mole = BaseUnit!("mole", "mol");
alias Second = BaseUnit!("second", "s");
alias Radian = BaseUnit!("radian", "rad");
alias Steradian = BaseUnit!("steradian", "sr");

enum ampere = Ampere.init;
enum candela = Candela.init; /// ditto
enum gram = Gram.init; /// ditto
enum kilogram = kilo!gram; /// ditto
enum kelvin = Kelvin.init; /// ditto
enum metre = Metre.init; /// ditto
alias meter = metre; /// ditto
enum mole = Mole.init; /// ditto
enum second = Second.init; /// ditto

/**
 * SI supplementary units for angles.
 */
enum radian = Radian.init;
enum steradian = Steradian.init; /// ditto

import std.math : PI;

enum PI_OVER_180 = PI/180;
enum _180_OVER_PI = 180/PI;

/**
 * SI scaled units for angles.
 */
// enum degree = PI_OVER_180 * radian; // TODO Use own convertible type:
enum degree = scale!(radian, PI/180, "degree");

// TODO Celsius: Use AffineUnit
// TODO Fahrenheit: Add and use LinearUnit

unittest
{
    import std.conv, std.format;
    alias Kilogram = PrefixedUnit!(Gram, 3, SiPrefixSystem);

    //pragma(msg, UnitExp!(typeof(gram / mole)));
    //pragma(msg, UnitExp!(typeof(milli!gram / milli!mole)));
    //static assert(is(UnitExp!(typeof(gram / mole)) : UnitExp!(typeof(milli!gram / milli!mole))));

    static assert(isConvertibleTo!(Gram)(1f * kilogram));

    Quantity!Gram mass1;
    mass1 = (485f * kilogram);
    assert(mass1.toValue == 485f * 10^^3);
    
    version(autoConvert) Quantity!Gram mass2 = (485.0 * kilogram);
    else Quantity!Gram mass2 = (485.0 * kilogram).convert!Gram;
    assert(mass1 == mass2);

    Quantity!Kilogram mass3 = mass1;
    assert(mass1.toValue == mass3.toValue*1000, format("`mass1` = %s, `mass3` = %s", mass1.toValue, mass3.toValue));
    assert(mass1 == mass3);

    Quantity!(Gram, float) mass4 = 2532.0 * milli!gram;
    
    //mass1 = cast(Quantity!(Gram)(423.0);

    alias GramPerMole = typeof(gram / mole);
    Quantity!GramPerMole molMass = mass2 / mole;
    molMass = 94f * milli!gram / milli!mole;
    molMass = 37f * kilo!gram * milli!gram / gram / mole;

    Quantity!(typeof(milli!mole))[10] millimoleArray;
    for(ushort i=0; i<10; i++) {
        millimoleArray[i] = (i * 35.0 * mass2 / milli!gram) * pico!mole;
    }

    /*Quantity!(typeof(milli!meter))[char] lengthMap;
    lengthMap = [
        'a': 4545560.456 * micro!meter,
        'b': 16.73865 * centi!meter
    ];*/

    alias Litre = BaseUnit!("litre", "L");
    Quantity!Litre sphereVolume(Q:Quantity!(Unit, V), Unit, V)(Q diameter)
        if(isConvertibleTo!(Unit, Metre))
    {
        Quantity!Metre radius = diameter / 2;
        return Litre.init* 3 * pow!(3,1)(radius).toValue / 4000;
    }
    static assert(isConvertibleTo!(Metre, typeof(centi!metre)));
    auto ballCapacity = sphereVolume(40.0 * centi!metre);
}

auto cos(Q)(Q angle)
    if (Q.init.isConvertibleTo!radian) // TODO Fix and use ConvertibleTo?
{
    import std.math : cos;
    return cos(angle.convert!radian.toValue);
}

auto sin(Q)(Q angle)
    if (Q.init.isConvertibleTo!radian)
{
    import std.math : sin;
    return sin(angle.convert!radian.toValue);
}

auto tan(Q)(Q angle)
    if (Q.init.isConvertibleTo!radian)
{
    import std.math : tan;
    return tan(angle.convert!radian.toValue);
}

auto expi(Q)(Q angle)
    if (Q.init.isConvertibleTo!radian)
{
    import std.math : expi;
    return expi(angle.convert!radian.toValue);
}

///
@safe pure unittest
{
    import std.math : isClose;
    import std.conv;
    static import std.math;

    assert(0.0*radian < 1.0*radian);
    // TODO fix Quantitiy.opCmp to allow: assert(0.0*radian < 1.0*degree);

    assert(isClose(cos(0.0*radian), 1));
    assert(isClose(cos(PI*radian), -1));
    assert(isClose(cos(2*PI*radian), 1));

    enum d = (180*degree);
    // pragma(msg, d.stringof ~ " : " ~ typeof(d).stringof);

    enum r = d.convert!radian;
    // pragma(msg, r.stringof ~ " : " ~ typeof(r).stringof);

    // TODO enable when cast in ScaledUnit.{to|from}Base have been removed:
    // TODO assert(isClose(cos(180*degree), -1));

    // The following asserts will only be run if the `sin` function in `std.math` is fixed.
    assert(isClose(sin(0.0*radian), 0));
    assert((isClose(sin(PI*radian), 0)) | (sin(PI*radian)==std.math.sin(PI)));
    assert((isClose(sin(2*PI*radian), 0)) | (sin(2*PI*radian)==std.math.sin(2*PI)), sin(2*PI*radian).to!string);
    // TODO enable when cast in ScaledUnit.{to|from}Base have been removed:
    // TODO assert(isClose(sin(360*degree), 0));
    if(std.math.sin(2*PI)==0) assert(isClose(sin(PI*radian), 0));

    // assert(isClose(expi(0.0*radian)!0.toValue, 0));
}

/**
 * SI derived units.
 */
enum hertz = dimensionless / second;
enum newton = kilogram * metre / pow!2(second); /// ditto
enum pascal = newton / pow!2(metre); /// ditto
enum joule = newton * metre; /// ditto
enum watt = joule / second; /// ditto
enum coulomb = ampere * second; /// ditto
enum volt = watt / ampere; /// ditto
enum farad = coulomb / volt; /// ditto
enum ohm = volt / ampere; /// ditto
enum siemens = ampere / volt; /// ditto
enum weber = volt * second; /// ditto
enum tesla = weber / pow!2(metre); /// ditto
enum henry = weber / ampere; /// ditto
enum lumen = candela * steradian; /// ditto
enum lux = lumen / pow!2(metre); /// ditto
enum becquerel = dimensionless / second; /// ditto
enum gray = joule / kilogram; /// ditto
enum sievert = joule / kilogram; /// ditto
enum katal = mole / second; /// ditto

///
@safe pure nothrow @nogc unittest
{
    auto work(Quantity!newton force, Quantity!metre displacement)
    {
        return force * displacement;
    }

    Quantity!(mole, V) idealGasAmount(V)(Quantity!(pascal, V) pressure,
        Quantity!(pow!3(meter), V) volume, Quantity!(kelvin, V) temperature)
    {
        enum R = 8.314471 * joule / (kelvin * mole);
        return (pressure * volume) / (temperature * R);
    }

    enum forcef = 1.0f * newton;
    enum force = 1.0 * newton;

    // compare quantities with different value types
    assert(forcef == force);
    static assert(forcef == force);

    enum displacement = 1.0 * metre;
    enum Quantity!joule e = work(force, displacement);
    static assert(e == 1.0 * joule);

    enum T = (273. + 37.) * kelvin;
    enum p = 1.01325e5 * pascal;
    enum r = 0.5e-6 * meter;
    enum V = (4.0 / 3.0) * 3.141592 * r.pow!3;
    enum n = idealGasAmount!double(p, V, T); // Need to explicitly specify double due to @@BUG5801@@.
    // TODO is this needed: static assert(n == 0xb.dd95ef4ddcb82f7p-59 * mole);

    static assert((2 * kilogram).convert!gram == 2000 * gram);
    static assert((2000 * gram).convert!kilogram == 2 * kilogram);
    static assert((1000 * newton).convert!(milli!newton) == 1000000 * milli!newton);
    static assert((2000000 * gram * meter / second.pow!2).convert!(kilo!newton) == 2 * kilo!newton);
    static assert((1234.0 * micro!newton / milli!metre.pow!2).convert!pascal == 1234.0 * pascal);
}
