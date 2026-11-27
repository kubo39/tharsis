module kernel.types;

@nogc:
nothrow:
@safe:

struct PAddr
{
    mixin AddressOps;
}
static assert(PAddr.sizeof == 8);

struct VAddr
{
    mixin AddressOps;
}
static assert(VAddr.sizeof == 8);

private mixin template AddressOps()
{
@nogc:
nothrow:
pragma(inline, true):

    this(ulong raw) pure
    {
        this.raw = raw;
    }

    T opCast(T)() const pure
        if (is(T == ulong))
    {
        return raw;
    }

    typeof(this) opBinary(string op)(ulong rhs) const pure
        if (op == "+" || op == "-")
    {
        return typeof(this)(mixin("raw " ~ op ~ " rhs"));
    }

    ulong opBinary(string op)(uint rhs) const pure
        if (op == ">>" || op == "<<")
    {
        return mixin("raw " ~ op ~ " rhs");
    }

    ulong opBinary(string op)(ulong rhs) const pure
        if (op == "*" || op == "/" || op == "%")
    {
        return mixin("raw " ~ op ~ " rhs");
    }

    ulong opBinary(string op)(typeof(this) rhs) const pure
        if (op == "-")
    {
        return raw - rhs.raw;
    }

    ref typeof(this) opOpAssign(string op)(ulong rhs) return pure
        if (op == "+" || op == "-")
    {
        mixin("raw " ~ op ~ "= rhs;");
        return this;
    }

    int opCmp(typeof(this) rhs) const pure
    {
        return (raw > rhs.raw) - (raw < rhs.raw);
    }

private:
    ulong raw;
}
