module C2017



struct FlexuralProperties

    Es::Float64

    fc::Float64
    β1::Float64
    ϵcu::Float64
    
    d::Float64
    
    ρ::Float64

    c_over_d::Float64
    c_over_d_b::Float64

    My::Float64
    Mr_LRFD::Float64
    Mr_ASD::Float64
    
    m::Float64
    c::Float64 
    Mro_LRFD::Float64
    Mro_ASD::Float64
        
end



function EqA3__3(As, Fy, fc, d, b, β1)

    c_over_d = (As * Fy) / (0.85 * fc * d * b * β1)

end

function EqA3__4(h, dd, Fy, Es, d)

    c_over_d_b = (0.003 * (h - dd)) / ((Fy / Es + 0.003) * d)

end

function EqA3__5a(My)

    ϕs = 0.85
    Mr = ϕs * My 

    return Mr

end

function EqA3__5b(My)

    Ωs = 1.75
    Mr = My / Ωs

    return Mr

end


function EqA3__6a(fc, b, β1, c, d, My)

    ϕc = 0.65
    ϕs = 0.85

    Mro = minimum([ϕc * fc * b * β1 * c * (d - β1 * c / 2), ϕs * My])

    return Mro

end

function EqA3__6b(fc, b, β1, c, d, My)

    Ωc = 2.30
    Ωs = 1.75
    Mro = minimum([(fc * b * β1 * c * (d - β1 * c / 2)) / Ωc, My / Ωs])

    return Mro

end

function EqA3__7(d, ρ, m)

    c = d * (sqrt(ρ * m + (ρ * m / 2)^2) - ρ * m / 2)

end

function EqA3__8(As, b, d)

    ρ = As / (b * d)

end

function EqA3__9(Es, ϵcu, fc, β1)

    m = (Es * ϵcu) / (fc * β1)

end


function EqA5__1(d, ρ, n, hc)

    ycc = minimum([d * (sqrt(2 * ρ * n + (ρ * n)^2) - ρ * n), hc])

end

function Eq_A5__2(b, n, ycc, As, ycs, Isf)

    Icr = b / (3 * n) * ycc^3 + As * ycs^2 + Isf

end


function SectionA3__3_flexural_strength(Es, fc, β1, d, ρ)


    c_over_d = SDIComposite.C2017.EqA3__3(As, Fy, fc, d, b, β1)

    c_over_d_b = SDIComposite.C2017.EqA3__4(h, dd, Fy, Es, d)

    My = (Fy * Icr) / (h - ycc)

    if c_over_d < c_over_d_b

        Mr_LRFD =  SDIComposite.C2017.Eq_A3__5a(My)
        Mr_ASD =  SDIComposite.C2017.Eq_A3__5b(My)

        flexural_properties = FlexuralProperties(

            Es, 

            fc, 
            β1, 
            ϵcu, 
        
            d, 
        
            ρ, 

            c_over_d, 
            c_over_d_b, 

            My,
            Mr_LRFD,
            Mr_ASD,
        
            Nothing,
            Nothing,
            Nothing,
            Nothing)

    elseif c_over_d >= c_over_d_b

        ϵcu = 0.003

        m = SDIComposite.C2017.EqA3__9(Es, ϵcu, fc, β1)

        c = SDIComposite.C2017.EqA3__7(d, ρ, m)

        Mro_LRFD = SDIComposite.C2017.EqA3__6a(fc, b, β1, c, d, My)

        Mro_ASD = SDIComposite.C2017.EqA3__6b(fc, b, β1, c, d, My)

        flexural_properties = FlexuralProperties(

        Es, 

        fc, 
        β1, 
        ϵcu, 
    
        d, 
    
        ρ, 

        c_over_d, 
        c_over_d_b, 

        My,
        Nothing,
        Nothing,
    
        m,
        c,
        Mro_LRFD,
        Mro_ASD)

    end

    return flexural_properties

end


end