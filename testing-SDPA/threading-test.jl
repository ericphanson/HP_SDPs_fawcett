using Convex, SDPA
using BenchmarkTools, Suppressor


function makeproblem()
    d = 50; n = 1
    C = randn(d, d)
    C = C' * C
    
    A = [ randn(d, d) for i = 1:n]
    b = randn(n)
    X = Variable(d, d)

    constraints = Constraint[ tr(A[i] * X) == b[i] for i = 1:n]
    push!(constraints, X ⪰ 0)
    problem = minimize(tr(C*X), constraints)
    return problem
end

if haskey(ENV, "OMP_NUM_THREADS")
    @info "Threading setting: " ENV["OMP_NUM_THREADS"]
else
    @info "ENV[\"OMP_NUM_THREADS\"] not set"
end

@info "Start of runs"

@info "First run"
problem = makeproblem()
@time solve!(problem, SDPASolver())


@info "2nd run"
problem = makeproblem()
@time solve!(problem, SDPASolver())

@info "3rd run"
problem = makeproblem()
@time solve!(problem, SDPASolver())

@info "Benchmark run:"
@benchmark @suppress(solve!(problem, SDPASolver())) setup=(problem = makeproblem()) evals=1


@info "End of runs."