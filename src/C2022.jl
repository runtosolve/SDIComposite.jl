module C2022

using OrderedCollections, AISIS100

struct FlexuralProperties

    Es

    fc
    β1
    ϵcu

    K1
    K3
    K

    d

    ρ

    c_over_d
    c_over_d_b

    My
    Mn_LRFD
    Mn_ASD

    m
    c

end

struct OneWayShearInputs

    t
    steel_deck_depth
    steel_deck_web_angle_from_horizon
    steel_deck_radius
    steel_deck_trough_width
    number_of_troughs_in_panel
    unit_width

    total_slab_depth

    Fy
    E
    μ

    kv

    λ
    fc

end

struct OneWayShearOutputs

    inputs

    h
    Aw
    Vy
    Fcr
    Vcr
    VD

    Δ_pitch
    Ac
    Vc
    aVn_per_pitch
    aVn_unit

end


"""
    EqF_4_1a(Vc, VD, fc, Ac)

SDI C-2022 EqF_4_1a — LRFD one-way shear strength.

Returns the design shear strength `ϕVn` (lbf) as the minimum of:
- `ϕv·Vc + ϕs·VD` (combined concrete + steel deck contribution), and
- `ϕv·4√fc·Ac` (concrete crushing upper bound).

# Arguments
- `Vc`: nominal concrete shear strength (lbf)
- `VD`: nominal steel deck shear strength (lbf)
- `fc`: concrete compressive strength (psi)
- `Ac`: concrete shear area (in²)

!!! note "Unit consistency — 1000 factor intentionally multiplied"
    All force terms (`Vc`, `VD`, `aVn`) are in **lbf** and `fc` is in **psi**,
    so `4√fc·Ac` is already in lbf. "1000" is intentionally multiplied here to remain consistent with the lbf unit system
    used throughout.
"""
function EqF_4_1a(Vc, VD, fc, Ac)

    ϕv = 0.75
    ϕs = 0.85
    aVn = minimum([ϕv * Vc + ϕs * VD, (ϕv * 0.004 * 1000 * sqrt(fc) * Ac)])

    return aVn

end

"""
    EqF_4_2a(Vc, VD, fc, Ac)

SDI C-2022 EqF_4_2a — ASD one-way shear strength.

Returns the allowable shear strength `aVn` (lbf) as the minimum of:
- `Vc/Ωv + VD/Ωs` (combined concrete + steel deck contribution), and
- `4√fc·Ac / Ωv` (concrete crushing upper bound).

# Arguments
- `Vc`: nominal concrete shear strength (lbf)
- `VD`: nominal steel deck shear strength (lbf)
- `fc`: concrete compressive strength (psi)
- `Ac`: concrete shear area (in²)

!!! note "Unit consistency — 1000 factor intentionally multiplied"
    All force terms (`Vc`, `VD`, `aVn`) are in **lbf** and `fc` is in **psi**,
    so `4√fc·Ac` is already in lbf. "1000" is intentionally multiplied here to remain consistent with the lbf unit system
    used throughout.
"""
function EqF_4_2a(Vc, VD, fc, Ac)

    Ωv = 2.00
    Ωs = 1.75
    aVn = minimum([Vc / Ωv + VD / Ωs, (0.004 * 1000 * sqrt(fc) * Ac) / Ωv])

    return aVn

end

function EqF_4_3a(λ, fc, Ac)

    Vc = 2 * λ * sqrt(fc) * Ac

end


function Appendix2_simple_span_Eq_C_A2_1_to_C_A2_3(P, W1, W2, W3, ℓ)

    M_plus_1 = 0.25 * P * ℓ + 0.125 * W1 * ℓ^2
    M_plus_2 = 0.125 * (W1 + W2) * ℓ^2
    M_plus_3 = 0.125 * W3 * ℓ^2
    M_plus = maximum([M_plus_1, M_plus_2, M_plus_3])

    return M_plus_1, M_plus_2, M_plus_3, M_plus

end

function Appendix2_double_span_Eq_C_A2_8_to_C_A2_12(P, W1, W2, W3, ℓ)

    M_plus_1 = 0.203 * P * ℓ + 0.096 * W1 * ℓ^2
    M_plus_2 = 0.096 * (W1 + W2) * ℓ^2
    M_plus_3 = 0.096 * W3 * ℓ^2
    M_plus = maximum([M_plus_1, M_plus_2, M_plus_3])

    M_neg_1 = 0.125 * (W1 + W2) * ℓ^2
    M_neg_2 = 0.125 * W3 * ℓ^2
    M_neg = maximum([M_neg_1, M_neg_2])

    return M_plus_1, M_plus_2, M_plus_3, M_plus, M_neg_1, M_neg_2, M_neg

end

function Appendix2_triple_span_Eq_C_A2_20_to_C_A2_24(P, W1, W2, W3, ℓ)

    M_plus_1 = 0.20 * P * ℓ + 0.094 * W1 * ℓ^2
    M_plus_2 = 0.094 * (W1 + W2) * ℓ^2
    M_plus_3 = 0.094 * W3 * ℓ^2
    M_plus = maximum([M_plus_1, M_plus_2, M_plus_3])

    M_neg_1 = 0.117 * (W1 + W2) * ℓ^2
    M_neg_2 = 0.117 * W3 * ℓ^2
    M_neg = maximum([M_neg_1, M_neg_2])

    return M_plus_1, M_plus_2, M_plus_3, M_plus, M_neg_1, M_neg_2, M_neg

end

function Appendix2_simple_span_Eq_C_A2_4_to_C_A2_6(W1, W2, W3, ℓ, P)

    P_ext_1 = 0.5 * W1 * ℓ + P
    P_ext_2 = 0.5 * (W1 + W2) * ℓ
    P_ext_3 = 0.5 * W3 * ℓ

    return P_ext_1, P_ext_2, P_ext_3

end

function Appendix2_double_span_Eq_C_A2_13_to_C_A2_18(W1, W2, W3, ℓ, P)

    P_ext_1 = 0.375 * W1 * ℓ + P
    P_int_1 = 1.25 * W1 * ℓ + P

    P_ext_2 = 0.375 * (W1 + W2) * ℓ
    P_int_2 = 1.25 * (W1 + W2) * ℓ

    P_ext_3 = 0.375 * W3 * ℓ
    P_int_3 = 1.25 * W3 * ℓ

    return P_ext_1, P_ext_2, P_ext_3, P_int_1, P_int_2, P_int_3

end

function Appendix2_triple_span_Eq_C_A2_25_to_C_A2_30(W1, W2, W3, ℓ, P)

    P_ext_1 = 0.4 * W1 * ℓ + P
    P_int_1 = 1.1 * W1 * ℓ + P

    P_ext_2 = 0.4 * (W1 + W2) * ℓ
    P_int_2 = 1.1 * (W1 + W2) * ℓ

    P_ext_3 = 0.4 * W3 * ℓ
    P_int_3 = 1.1 * W3 * ℓ

    return P_ext_1, P_ext_2, P_ext_3, P_int_1, P_int_2, P_int_3

end

function Appendix2_simple_span_Eq_C_A2__7(W1, ℓ, E, I)

    Δ = 0.0130 * W1 * ℓ^4 / (E * I)

end

function Appendix2_double_span_Eq_C_A2_19(W1, ℓ, E, I)

    Δ = 0.0054 * W1 * ℓ^4 / (E * I)

end

function Appendix2_triple_span_Eq_C_A2_31(W1, ℓ, E, I)

    Δ = 0.0069 * W1 * ℓ^4 / (E * I)

end


function EqF_3_2__6(K1, K3)

    K = minimum([K3 / K1, 1.0])

end

function EqF3_2__7_type_1(Dw, ph)

    K1 = minimum([0.07 * Dw^0.5 / ph, 1.55])

end

function EqF3_2__8_type_2(t, Dw, ph)

    K1 = 15 * t / (Dw * ph^0.5)

end

function EqF3_2__9_type_3(K11, K12, ps1, ps2)

    K1 = (K11 * ps1 + K12 * ps2) / (ps1 + ps2)

end

function EqF3_2__10(K, My, design_code) #Supplement_1_FINAL_2026_3_1   
    # α = 1 (in feet)
    if design_code == "ASD"
        Ω = 1.75
        Mn = K * My / Ω

    elseif design_code == "LRFD"
        ϕ = 0.85
        Mn = K * My * ϕ
    end

    return Mn

end

function EqF3_2__11(Fy, Icr, h, ycc)

    My = (Fy * Icr) / (h - ycc)

end


function EqC_F2_2__1(As, Fy, fc, d, b, β1)

    c_over_d = (As * Fy) / (0.85 * fc * d * b * β1)

end

function EqC_F2_2__2(h, dd, Fy, Es, d)

    c_over_d_b = (0.003 * (h - dd)) / ((Fy / Es + 0.003) * d)

end

function EqC_F2_3_1(d, ρ, n, hc)

    ycc = minimum([d * (sqrt(2 * ρ * n + (ρ * n)^2) - ρ * n), hc])

end

function EqC_F2_3_2(b, n, ycc, As, ycs, Isf)

    Icr = b / (3 * n) * ycc^3 + As * ycs^2 + Isf

end

function EqC_F2_3_3(b, hc, n, As, d, Wr, dd, h, Cs)

    ycc = (0.5 * b * hc^2 + n * As * d + Wr * dd * (h - 0.5 * dd) * (b / Cs)) / (b * hc + n * As + Wr * dd * (b / Cs))

end

function EqC_F2_3_4(b, h, hc, n, ycc, Isf, As, ycs, Wr, dd, Cs)

    Iu = (b * hc^3) / (12 * n) + ((b * hc) / n) * (ycc - 0.5 * hc)^2 + Isf + As * ycs^2 + ((Wr * b * dd) / (n * Cs)) * (dd^2 / 12 + (h - ycc - 0.5 * dd)^2)

end

function EqC_F2_3_5(Iu, Ic)

    Id = (Iu + Ic) / 2

end


function EqC_F3_1_1(fc, b, β1, c, d)

    Mn = 0.85 * fc * b * β1 * c * (d - β1 * c / 2)

    return Mn

end

function EqC_F3_1_2(d, ρ, m)

    c = d * (sqrt(ρ * m + (ρ * m / 2)^2) - ρ * m / 2)

end

function EqC_F3_1_3(As, b, d)

    ρ = As / (b * d)

end

function EqC_F3_1_4(Es, ϵcu, fc, β1)

    m = (Es * ϵcu) / (fc * β1)

end

function EqC_F3_1_5(As, Fy, d, a)

    Mn = (As * Fy) / (d - a / 2)

    return Mn

end

function EqC_F3_1_6(As, Fy, fc, b)

    a = As * Fy / (0.85 * fc * b)

end


end
