
# TODO: uncomment vexity checks once SDP on vars/constraints changes vexity of problem
@testset "SDP Atoms: $solver" for solver in solvers
    if can_solve_sdp(solver)
        @testset "sdp variables" begin
            y = Variable((2,2), :Semidefinite)
            p = minimize(y[1,1])
            # @fact vexity(p) --> ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 0 atol=TOL

            y = Variable((3,3), :Semidefinite)
            p = minimize(y[1,1], y[2,2]==1)
            # @fact vexity(p) --> ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 0 atol=TOL

            # Solution is obtained as y[2,2] -> infinity
            # This test fails on Mosek. See
            # https://github.com/JuliaOpt/Mosek.jl/issues/29
            # y = Variable((2, 2), :Semidefinite)
            # p = minimize(y[1, 1], y[1, 2] == 1)
            # # @fact vexity(p) --> ConvexVexity()
            # solve!(p, solver)
            # @fact p.optval --> roughly(0, TOL)

            y = Semidefinite(3)
            p = minimize(sum(diag(y)), y[1, 1] == 1)
            # @fact vexity(p) --> ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 1 atol=TOL

            y = Variable((3, 3), :Semidefinite)
            p = minimize(tr(y), y[2,1]<=4, y[2,2]>=3)
            # @fact vexity(p) --> ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 3 atol=TOL

            x = Variable(Positive())
            y = Semidefinite(3)
            p = minimize(y[1, 2], y[2, 1] == 1)
            # @fact vexity(p) --> ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 1 atol=TOL
        end

        @testset "sdp constraints" begin
            # This test fails on Mosek
            x = Variable(Positive())
            y = Variable((3, 3))
            p = minimize(x + y[1, 1], isposdef(y), x >= 1, y[2, 1] == 1)
            # @fact vexity(p) --> ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 1 atol=TOL
        end

        @testset "nuclear norm atom" begin
            y = Semidefinite(3)
            p = minimize(nuclearnorm(y), y[2,1]<=4, y[2,2]>=3, y[3,3]<=2)
            @test vexity(p) == ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 3 atol=TOL
            @test evaluate(nuclearnorm(y)) ≈ 3 atol=TOL
        end

        @testset "operator norm atom" begin
            y = Variable((3,3))
            p = minimize(opnorm(y), y[2,1]<=4, y[2,2]>=3, sum(y)>=12)
            @test vexity(p) == ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 4 atol=TOL
            @test evaluate(opnorm(y)) ≈ 4 atol=TOL
        end

        @testset "sigma max atom" begin
            y = Variable((3,3))
            p = minimize(sigmamax(y), y[2,1]<=4, y[2,2]>=3, sum(y)>=12)
            @test vexity(p) == ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 4 atol=TOL
            @test evaluate(sigmamax(y)) ≈ 4 atol=TOL
        end

        @testset "lambda max atom" begin
            y = Semidefinite(3)
            p = minimize(lambdamax(y), y[1,1]>=4)
            @test vexity(p) == ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 4 atol=TOL
            @test evaluate(lambdamax(y)) ≈ 4 atol=TOL
        end

        @testset "lambda min atom" begin
            y = Semidefinite(3)
            p = maximize(lambdamin(y), tr(y)<=6)
            @test vexity(p) == ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 2 atol=TOL
            @test evaluate(lambdamin(y)) ≈ 2 atol=TOL
        end

        @testset "matrix frac atom" begin
            x = [1, 2, 3]
            P = Variable(3, 3)
            p = minimize(matrixfrac(x, P), P <= 2*eye(3), P >= 0.5 * eye(3))
            @test vexity(p) == ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 7 atol=TOL
            @test (evaluate(matrixfrac(x, P)))[1] ≈ 7 atol=TOL
        end

        @testset "matrix frac atom both arguments variable" begin
            x = Variable(3)
            P = Variable(3, 3)
            p = minimize(matrixfrac(x, P), lambdamax(P) <= 2, x[1] >= 1)
            @test vexity(p) == ConvexVexity()
            solve!(p, solver)
            @test p.optval ≈ 0.5 atol=TOL
            @test (evaluate(matrixfrac(x, P)))[1] ≈ 0.5 atol=TOL
        end

        @testset "sum largest eigs" begin
            x = Semidefinite(3)
            p = minimize(sumlargesteigs(x, 2), x >= 1)
            solve!(p, solver)
            @test p.optval ≈ 3 atol=TOL
            @test evaluate(x) ≈ ones(3, 3) atol=TOL

            x = Semidefinite(3)
            p = minimize(sumlargesteigs(x, 2), [x[i,:] >= i for i=1:3]...)
            solve!(p, solver)
            @test p.optval ≈ 8.4853 atol=TOL

            x1 = Semidefinite(3)
            p1 = minimize(lambdamax(x1), x1[1,1]>=4)
            solve!(p1, solver)

            x2 = Semidefinite(3)
            p2 = minimize(sumlargesteigs(x2, 1), x2[1,1]>=4)
            solve!(p2, solver)

            @test p1.optval ≈ p2.optval atol=TOL

            x1 = Semidefinite(3)
            p1 = minimize(lambdamax(x1), [x1[i,:] >= i for i=1:3]...)
            solve!(p1, solver)

            x2 = Semidefinite(3)
            p2 = minimize(sumlargesteigs(x2, 1), [x2[i,:] >= i for i=1:3]...)
            solve!(p2, solver)

            @test p1.optval ≈ p2.optval atol=TOL

            println(p1.optval)
        end

        @testset "kron atom" begin
            id = eye(4)
            X = Semidefinite(4)
            W = kron(id, X)
            p = maximize(tr(W), tr(X) ≤ 1)
            @test vexity(p) == AffineVexity()
            solve!(p, solver)
            @test p.optval ≈ 4 atol=TOL
        end

        @testset "Partial trace" begin
            A = Semidefinite(2)
            B = [1 0; 0 0]
            ρ = kron(B, A)
            constraints = [partialtrace(ρ, 1, [2; 2]) == [0.09942819 0.29923607; 0.29923607 0.90057181], ρ in :SDP]
            p = satisfy(constraints)
            solve!(p, solver)
            @test evaluate(ρ) ≈ [0.09942819 0.29923607 0 0; 0.299237 0.900572 0 0; 0 0 0 0; 0 0 0 0] atol=TOL
            @test evaluate(partialtrace(ρ, 1, [2; 2])) ≈ [0.09942819 0.29923607; 0.29923607 0.90057181] atol=TOL

            function rand_normalized(n)
                A = 5*randn(n, n) + im*5*randn(n, n)
                A / tr(A)
            end

            As = [ rand_normalized(3) for _ = 1:5]
            Bs = [ rand_normalized(2) for _ = 1:5]
            p = rand(5)

            AB = sum(i -> p[i]*kron(As[i],Bs[i]), 1:5)
            @test partialtrace(AB, 2, [3, 2]) ≈ sum( p .* As )
            @test partialtrace(AB, 1, [3, 2]) ≈ sum( p .* Bs )

            A, B, C = rand(5,5), rand(4,4), rand(3,3)
            ABC = kron(kron(A, B), C)
            @test kron(A,B)*tr(C) ≈ partialtrace(ABC, 3, [5, 4, 3])

            # Test 281
            A = rand(6,6)
            expr = partialtrace(Constant(A), 1, [2, 3])
            @test size(expr) == size(evaluate(expr))

            @test_throws ArgumentError partialtrace(rand(6, 6), 3, [2, 3])
            @test_throws ArgumentError partialtrace(rand(6, 6), 1, [2, 4])
            @test_throws ArgumentError partialtrace(rand(3, 4), 1, [2, 3])
        end

        @testset "Optimization with complex variables" begin
            @testset "Real Variables with complex equality constraints" begin
                n = 10 # variable dimension (parameter)
                m = 5 # number of constraints (parameter)
                xo = rand(n)
                A = randn(m,n) + im*randn(m,n)
                b = A * xo
                x = Variable(n)
                p1 = minimize(sum(x), A*x == b, x>=0)
                solve!(p1, solver)
                x1 = x.value

                p2 = minimize(sum(x), real(A)*x == real(b), imag(A)*x==imag(b), x>=0)
                solve!(p2, solver)
                x2 = x.value
                @test x1 == x2
            end

            @testset "Complex Variable with complex equality constraints" begin
                n = 10 # variable dimension (parameter)
                m = 5 # number of constraints (parameter)
                xo = rand(n)+im*rand(n)
                A = randn(m,n) + im*randn(m,n)
                b = A * xo
                x = ComplexVariable(n)
                p1 = minimize(real(sum(x)), A*x == b, real(x)>=0, imag(x)>=0)
                solve!(p1, solver)
                x1 = x.value

                xr = Variable(n)
                xi = Variable(n)
                p2 = minimize(sum(xr), real(A)*xr-imag(A)*xi == real(b), imag(A)*xr+real(A)*xi == imag(b), xr>=0, xi>=0)
                solve!(p2, solver)
                #x2 = xr.value + im*xi.value
                real_diff = real(x1) - xr.value

                @test real_diff ≈ zeros(10, 1) atol=TOL
                imag_diff = imag(x1) - xi.value
                @test imag_diff ≈ zeros(10, 1) atol=TOL
                #@fact x1==x2 --> true
            end

            @testset "norm2 atom" begin
                a = 2+4im
                x = ComplexVariable()
                objective = norm2(a-x)
                c1 = real(x)>=0
                p = minimize(objective,c1)
                solve!(p, solver)
                @test p.optval ≈ 0 atol=TOL
                @test evaluate(objective) ≈ 0 atol=TOL
                real_diff = real(x.value) - real(a)
                imag_diff = imag(x.value) - imag(a)
                @test real_diff ≈ 0 atol=TOL
                @test imag_diff ≈ 0 atol=TOL
            end

            @testset "sumsquares atom" begin
                a = [2+4im;4+6im]
                x = ComplexVariable(2)
                objective = sumsquares(a-x)
                c1 = real(x)>=0
                p = minimize(objective,c1)
                solve!(p, solver)
                @test p.optval ≈ 0 atol=TOL
                @test evaluate(objective) ≈ zeros(1, 1) atol=TOL
                real_diff = real.(x.value) - real.(a)
                imag_diff = imag.(x.value) - imag.(a)
                @test real_diff ≈ zeros(2, 1) atol=TOL
                @test imag_diff ≈ zeros(2, 1) atol=TOL
            end

            @testset "abs atom" begin
                a = [5-4im]
                x = ComplexVariable()
                objective = abs(a-x)
                c1 = real(x)>=0
                p = minimize(objective,c1)
                solve!(p, solver)
                @test p.optval ≈ 0 atol=TOL
                @test evaluate(objective) ≈ zeros(1) atol=TOL
                real_diff = real(x.value) .- real(a)
                imag_diff = imag(x.value) .- imag(a)
                @test real_diff ≈ zeros(1) atol=TOL
                @test imag_diff ≈ zeros(1) atol=TOL
            end

            @testset "Complex Semidefinite constraint" begin
                n = 10
                A = rand(n,n) + im*rand(n,n)
                A = A + A' # now A is hermitian
                x = ComplexVariable(n,n)
                objective = sumsquares(A - x)
                c1 = x in :SDP
                p = minimize(objective, c1)
                solve!(p, solver)
                # test that X is approximately equal to posA:
                l,v = eigen(A)
                posA = v*Diagonal(max.(l,0))*v'

                real_diff = real.(x.value) - real.(posA)
                imag_diff = imag.(x.value) - imag.(posA)
                @test real_diff ≈ zeros(n, n) atol=TOL
                @test imag_diff ≈ zeros(n, n) atol=TOL
            end
        end
    end
end
