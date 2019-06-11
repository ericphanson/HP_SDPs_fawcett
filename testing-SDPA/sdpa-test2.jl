using Convex

using Convex: DotMultiplyAtom
using SDPA
using Random

import LinearAlgebra.eigen
import LinearAlgebra.I
import LinearAlgebra.opnorm
import Random.shuffle
import Statistics.mean

TOL = 1e-3
eye(n) = Matrix(1.0I, n, n)

# Seed random number stream to improve test reliability
Random.seed!(2)

solvers = [SDPASolver(Mode=PARAMETER_UNSTABLE_BUT_FAST)]

@info "Starting tests with mode PARAMETER_UNSTABLE_BUT_FAST"

@testset "Convex Mode=PARAMETER_UNSTABLE_BUT_FAST" begin
    include(joinpath("test", "test_utilities.jl"))
    include(joinpath("test", "test_const.jl"))
    include(joinpath("test", "test_affine.jl"))
    include(joinpath("test", "test_lp.jl"))
    include(joinpath("test", "test_socp.jl"))
    include(joinpath("test", "test_sdp.jl"))
    include(joinpath("test", "test_exp.jl"))
    include(joinpath("test", "test_sdp_and_exp.jl"))
    include(joinpath("test", "test_mip.jl"))
end
