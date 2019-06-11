using Convex

using Convex: DotMultiplyAtom
using SDPA
using Random
using Test

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

@info "Starting short tests with mode PARAMETER_UNSTABLE_BUT_FAST"

@testset "Convex Mode=PARAMETER_UNSTABLE_BUT_FAST" begin
    include(joinpath("test", "test_lp.jl"))
end
