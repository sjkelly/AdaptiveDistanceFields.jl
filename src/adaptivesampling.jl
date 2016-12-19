type SignedDistanceRefinery{F <: Function} <: AbstractRefinery
    signed_distance_func::F
    atol::Float64
    rtol::Float64
end

function needs_refinement(refinery::SignedDistanceRefinery, cell::Cell)
    needs_refinement(cell, refinery.signed_distance_func, refinery.atol, refinery.rtol)
end

function needs_refinement(cell::Cell, signed_distance_func, atol, rtol)
    for c in body_and_face_centers(cell.boundary)
        value_interp = evaluate(cell, c)
        value_true = signed_distance_func(c)
        if !isapprox(value_interp, value_true, rtol=rtol, atol=atol)
            return true
        end
    end
    false
end

function refine_data(refinery::SignedDistanceRefinery, cell::Cell, indices)
    refine_data(refinery, child_boundary(cell, indices))
end

function refine_data(refinery::SignedDistanceRefinery, boundary::HyperRectangle)
    interpolate!(refinery.signed_distance_func.(vertices(boundary)),
                 BSpline(Linear()),
                 OnGrid())
end

function ASDF(signed_distance::Function, origin::AbstractArray,
              widths::AbstractArray,
              rtol=1e-2,
              atol=1e-2)
    refinery = SignedDistanceRefinery(signed_distance, atol, rtol)
    boundary = HyperRectangle(origin, widths)
    root = Cell(boundary, refine_data(refinery, boundary))
    adaptivesampling!(root, refinery)
end
