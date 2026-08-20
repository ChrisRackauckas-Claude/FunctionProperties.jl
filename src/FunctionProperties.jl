module FunctionProperties

using Core: GotoIfNot

export hasbranching, is_leaf, islinear, isquadratic, isautonomous, issmooth,
    hasrandomness, hasmutation, ispure, isinferable

# Conservative detection of value-dependent branching by scanning type-inferred IR, with
# constant-argument refutation of branches that literals decide.
include("hasbranching.jl")

# Certification of polynomial degree (`islinear`, `isquadratic`) by abstract interpretation
# with a degree-tracking tracer number type.
include("polydegree.jl")

# Certification of smoothness by abstract interpretation with a smoothness tracer.
include("smoothprobe.jl")

# Conservative detection of reachable Random-stdlib calls.
include("randomness.jl")

# Certification of argument non-mutation by write-recording probe arrays.
include("writeprobe.jl")

# Capability-gated certificates over the compiler's effects and inference results.
include("effects.jl")

using PrecompileTools: @compile_workload, @setup_workload

@setup_workload begin
    @compile_workload begin
        linear = (x, p, t) -> p * x + t
        branchy = (x, p, t) -> x < 0 ? -x + p : x + p
        mutating = (dx, x) -> (dx[1] = x[1])
        x = [1.0]
        p = 2.0
        t = 0.0
        hasbranching(linear, x[1], p, t)
        hasbranching(branchy, x[1], p, t)
        islinear(linear, x[1], p, t)
        isquadratic(linear, x[1], p, t)
        isautonomous(linear, x[1], p, t)
        issmooth(linear, x[1], p, t)
        hasrandomness(linear, x[1], p, t)
        hasmutation(mutating, copy(x), x)
        ispure(linear, x[1], p, t)
        isinferable(linear, x[1], p, t)
    end
end

end
