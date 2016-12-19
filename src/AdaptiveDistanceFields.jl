module AdaptiveDistanceFields

using RegionTrees
import RegionTrees: needs_refinement, refine_data
using Interpolations
import StaticArrays: SVector

include("interpolation.jl")
include("adaptivesampling.jl")
include("meshdistance.jl")

immutable AdaptiveDistanceField{C <: Cell} <: Function
    root::C
end

function AdaptiveDistanceField(signed_distance::Function, origin::AbstractArray,
              widths::AbstractArray,
              rtol=1e-2,
              atol=1e-2)
    refinery = SignedDistanceRefinery(signed_distance, atol, rtol)
    boundary = HyperRectangle(origin, widths)
    root = Cell(boundary, refine_data(refinery, boundary))
    adaptivesampling!(root, refinery)
    AdaptiveDistanceField(root)
end

function (field::AdaptiveDistanceField)(point::AbstractArray)
    evaluate(field.root, point)
end

end
