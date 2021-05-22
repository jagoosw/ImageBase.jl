@testset "restrict" begin
    A = reshape([UInt16(i) for i = 1:60], 4, 5, 3)
    B = restrict(A, (1,2))
    Btarget = cat(   [  0.96875   4.625   5.96875;
                        2.875    10.5    12.875;
                        1.90625   5.875   6.90625],
                     [  8.46875  14.625  13.46875;
                       17.875    30.5    27.875;
                        9.40625  15.875  14.40625],
                     [ 15.96875  24.625  20.96875;
                       32.875    50.5    42.875;
                       16.90625  25.875  21.90625], dims=3)
    @test B ≈ Btarget
    Argb = reinterpretc(RGB, reinterpret(N0f16, permutedims(A, (3,1,2))))
    B = restrict(Argb)
    Bf = permutedims(reinterpretc(eltype(eltype(B)), B), (2,3,1))
    # isapprox no longer lies, so atol is now serious
    @test isapprox(Bf, Btarget/reinterpret(one(N0f16)), atol=1e-10)
    Argba = reinterpretc(RGBA{N0f16}, reinterpret(N0f16, A))
    B = restrict(Argba)
    @test isapprox(reinterpretc(eltype(eltype(B)), B), restrict(A, (2,3))/reinterpret(one(N0f16)), atol=1e-10)
    A = reshape(1:60, 5, 4, 3)
    B = restrict(A, (1,2,3))
    @test cat(   [  2.6015625   8.71875   6.1171875;
                    4.09375    12.875     8.78125;
                    3.5390625  10.59375   7.0546875],
                 [ 10.1015625  23.71875  13.6171875;
                   14.09375    32.875    18.78125;
                   11.0390625  25.59375  14.5546875], dims=3) ≈ B
    # Issue #395
    img1 = colorview(RGB, fill(0.9, 3, 5, 5))
    img2 = colorview(RGB, fill(N0f8(0.9), 3, 5, 5))
    @test isapprox(channelview(restrict(img1)), channelview(restrict(img2)), rtol=0.01)
    # Non-1 indices
    Ao = OffsetArray(A, (-2,1,0))
    @test parent(@inferred(restrict(Ao, 1))) == restrict(A, 1)
    @test parent(@inferred(restrict(Ao, 2))) == restrict(A, 2)
    @test parent(@inferred(restrict(Ao, (1,2)))) == restrict(A, (1,2))
    # Arrays-of-arrays
    a = Vector{Int}[[3,3,3], [2,1,7],[-11,4,2]]
    @test restrict(a) == Vector{Float64}[[2,3.5/2,6.5/2], [-5,4.5/2,5.5/2]]
    # Images issue #652
    img = testimage("cameraman")
    @test eltype(@inferred(restrict(img))) == Gray{Float32}
    img = testimage("mandrill")
    @test eltype(@inferred(restrict(img))) == RGB{Float32}
    @test eltype(@inferred(restrict(Lab.(img)))) == RGB{Float32}
    img = rand(RGBA{N0f8}, 11, 11)
    @test eltype(@inferred(restrict(img))) == RGBA{Float32}
    @test eltype(@inferred(restrict(LabA.(img)))) == ARGB{Float32}
end