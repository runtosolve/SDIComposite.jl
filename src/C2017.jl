module C2017

using OrderedCollections, AISIS100 

# struct FlexuralProperties

#     Es

#     fc
#     β1 
#     ϵcu

#     K1
#     K3
#     K
    
#     d
    
#     ρ

#     c_over_d
#     c_over_d_b

#     My
#     Mno_LRFD
#     Mno_ASD
    
#     m
#     c
#     Mro_LRFD
#     Mro_ASD
        
# end
####

# struct OneWayShearInputs 

#     t 
#     steel_deck_depth
#     steel_deck_web_angle_from_horizon
#     steel_deck_radius
#     steel_deck_trough_width 
#     number_of_troughs_in_panel
#     unit_width
    
#     total_slab_depth 

#     Fy
#     E 
#     μ

#     kv

#     λ
#     fc

# end



# struct OneWayShearOutputs

#     inputs

#     h 
#     Aw
#     Vy
#     Fcr
#     Vcr
#     VD
    
#     Δ_pitch 
#     Ac 
#     Vc 
#     aVn_per_pitch
#     aVn_unit 

# end






#####


function Eq2_4_7a(Vc, VD, fc, Ac)

    ϕv = 0.75
    ϕs = 0.85
    aVn = minimum([ϕv * Vc + ϕs * VD, (ϕv * 4 * sqrt(fc) * Ac) / 1000])

    return aVn

end

function Eq2_4_7c(Vc, VD, fc, Ac)

    Ωv = 2.00
    Ωs = 1.75
    aVn = minimum([Vc / Ωv + VD / Ωs, (4 * sqrt(fc) * Ac) / Ωv])
    # aVn = Vc / Ωv + VD / Ωs

    return aVn 

end

function Eq2_4_8_a(λ, fc, Ac)

    Vc = 2 * λ * sqrt(fc) * Ac

end


# function Section2_4_B_9_one_way_shear_strength(inputs)

#     (; t, 
#     steel_deck_depth,
#     steel_deck_web_angle_from_horizon,
#     steel_deck_radius,
#     steel_deck_trough_width, 
#     number_of_troughs_in_panel,
#     unit_width,
    
#     total_slab_depth, 

#     Fy,
#     E, 
#     μ,

#     kv,

#     λ,
#     fc) = inputs 

#     ####steel strength 

#     h = steel_deck_depth / sind(steel_deck_web_angle_from_horizon) - 2 * steel_deck_radius


#     Aw, Vy = AISIS100.v16S3.g215_6(h, t, Fy)

#     Fcr = AISIS100.v16S3.g232(E, μ, kv, h, t)

#     Vcr = AISIS100.v16S3.g231(h, t, Fcr)

#     design_code = "nominal"
#     VD, aVD = AISIS100.v16S3.g2_1__1_2_3(Vcr, Vy, design_code)


#     #####concrete strength 

#     Δ_pitch = total_slab_depth * tand(90.0 - steel_deck_web_angle_from_horizon)
#     Ac = mean([steel_deck_trough_width, steel_deck_trough_width + 2 * Δ_pitch]) * total_slab_depth


#     Vc = Eq2_4_8_a(λ, fc, Ac)

#     aVn_per_pitch = Eq2_4_7c(Vc, VD, fc, Ac)

#     aVn_unit = (aVn_per_pitch * number_of_troughs_in_panel) / unit_width

#     #package outputs 

#     outputs = OneWayShearOutputs(

#                 inputs,

#                 h, 
#                 Aw,
#                 Vy,
#                 Fcr,
#                 Vcr,
#                 VD,

#                 Δ_pitch, 
#                 Ac,
#                 Vc,
#                 aVn_per_pitch,
#                 aVn_unit 
#     )

#     return outputs 

# end




function Appendix1_Figure_1_simple_span(P, W1, W2, ℓ)

    M_plus_1 = 0.25 * P * ℓ + 0.125 * W1 * ℓ^2
    M_plus_2 = 0.125 * (W1 + W2) * ℓ^2
    M_plus = maximum([M_plus_1, M_plus_2])

    return M_plus_1, M_plus_2, M_plus 

end


function Appendix1_Figure_1_double_span(P, W1, W2, ℓ)

    M_plus_1 = 0.203 * P * ℓ + 0.096 * W1 * ℓ^2
    M_plus_2 = 0.096 * (W1 + W2) * ℓ^2
    M_plus = maximum([M_plus_1, M_plus_2])

    M_neg = 0.125 * (W1 + W2) * ℓ^2

    return M_plus_1, M_plus_2, M_plus, M_neg

end

function Appendix1_Figure_1_triple_span(P, W1, W2, ℓ)

    M_plus_1 = 0.20 * P * ℓ + 0.094 * W1 * ℓ^2
    M_plus_2 = 0.094 * (W1 + W2) * ℓ^2
    M_plus = maximum([M_plus_1, M_plus_2])

    M_neg = 0.117 * (W1 + W2) * ℓ^2

    return M_plus_1, M_plus_2, M_plus, M_neg

end

function Appendix1_Figure_2_simple_span(W1, W2, ℓ, P)

    P_ext_1 = 0.5 * W1 * ℓ + P
    P_ext_2 = 0.5 * (W1 + W2) * ℓ

    return P_ext_1, P_ext_2

end

function Appendix1_Figure_2_double_span(W1, W2, ℓ, P)

    P_ext_1 = 0.375 * W1 * ℓ + P
    P_int_1 = 1.25 * W1 * ℓ + P

    P_ext_2 = 0.375 * (W1 + W2) * ℓ
    P_int_2 = 1.25 * (W1 + W2) * ℓ

    return P_ext_1, P_ext_2, P_int_1, P_int_2

end

function Appendix1_Figure_2_triple_span(W1, W2, ℓ, P)

    P_ext_1 = 0.4 * W1 * ℓ + P
    P_int_1 = 1.1 * W1 * ℓ + P

    P_ext_2 = 0.4 * (W1 + W2) * ℓ
    P_int_2 = 1.1 * (W1 + W2) * ℓ

    return P_ext_1, P_ext_2, P_int_1, P_int_2

end




function Appendix1_Figure_3_simple_span(W1, ℓ, E, I)

    Δ = 0.0130 * W1 * ℓ^4  / (E * I)

end

function Appendix1_Figure_3_double_span(W1, ℓ, E, I)

    Δ = 0.0054 * W1 * ℓ^4  / (E * I)

end


function Appendix1_Figure_3_triple_span(W1, ℓ, E, I)

    Δ = 0.0069 * W1 * ℓ^4  / (E * I)

end





function EqA2__5(As, Fy, fc, d, b, β1)

    c_over_d = (As * Fy) / (0.85 * fc * d * b * β1)

end

function EqA2__6(h, dd, Fy, Es, d)

    c_over_d_b = (0.003 * (h - dd)) / ((Fy / Es + 0.003) * d)

end

function EqA2__8(K, My)

    Mno = K * My

end

function EqA2__9(Fy, Icr, h, ycc)

    My = (Fy * Icr) / (h - ycc)

end


function EqA2__10(K1, K3)

    K = minimum([K3 / K1, 1.0])

end


function EqA2__12(Dw, ph)

    K1 = minimum([0.07 * Dw^0.5 / ph, 1.55])

end


function EqA2__15(K, My)

    Ωs = 1.75  
    Mno_ASD = K * My / Ωs

end

function EqA2__16(K, My)

    ϕs = 0.85
    Mno_LRFD = ϕs * K * My

end


function EqA2__17a(fc, b, β1, c, d, My, K)

    ϕc = 0.65
    ϕs = 0.85

    Mro = minimum([ϕc * fc * b * β1 * c * (d - β1 * c / 2), ϕs * K * My])

    return Mro

end

function EqA2__17b(fc, b, β1, c, d, My, K)

    Ωc = 2.30
    Ωs = 1.75
    Mro = minimum([(fc * b * β1 * c * (d - β1 * c / 2)) / Ωc, K * My / Ωs])

    return Mro

end




function EqA2__18(d, ρ, m)

    c = d * (sqrt(ρ * m + (ρ * m / 2)^2) - ρ * m / 2)

end

function EqA2__19(As, b, d)

    ρ = As / (b * d)

end

function EqA2__20(Es, ϵcu, fc, β1)

    m = (Es * ϵcu) / (fc * β1)

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



function EqA5__1(d, ρ, n, hc)

    ycc = minimum([d * (sqrt(2 * ρ * n + (ρ * n)^2) - ρ * n), hc])

end

function EqA5__2(b, n, ycc, As, ycs, Isf)

    Icr = b / (3 * n) * ycc^3 + As * ycs^2 + Isf

end

function EqA5__3(b, hc, n, As, d, Wr, dd, h, Cs)

    ycc = (0.5 * b * hc^2 + n * As * d + Wr * dd * (h - 0.5 * dd) * (b / Cs)) / (b * hc + n * As + Wr * dd * (b / Cs))

end

function EqA5__4(b, h, hc, n, ycc, Isf, As, ycs, Wr, dd, Cs)

    Iu = (b * hc^3) / (12 * n) + ((b * hc) / n) * (ycc - 0.5 * hc)^2 + Isf + As * ycs^2 + ((Wr * b * dd) / (n * Cs)) * (dd^2 / 12 + (h - ycc - 0.5 * dd)^2)

end

function EqA5__5(Iu, Ic)

    Id = (Iu + Ic) / 2 

end

end