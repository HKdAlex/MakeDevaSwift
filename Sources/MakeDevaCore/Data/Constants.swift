/// Constants for Devanagari font glyph codes and distance codes
///
/// These constants match the definitions in `devaline.c` lines 45-153.
/// They define special glyph codes and distance codes used by the RM Devanagari font.
public enum FontConstants {
    // Distance codes for diacritics (from devaline.c lines 45-50)
    public static let D030: UInt8 = 0x22
    public static let D060: UInt8 = 0x23
    public static let D090: UInt8 = 0x24
    public static let D120: UInt8 = 0x25
    public static let D150: UInt8 = 0x26
    public static let D270: UInt8 = 0x28
    
    // Minimum distance for diacritics
    public static let MINDIST: Int = 60
    
    // Special codes (from devaline.h)
    public static let CODE_Nothing: UInt8 = 0xF0
    public static let CODE_Dash: UInt8 = CODE_Nothing
    public static let CODE_HalfLine: UInt8 = 9
    public static let CODE_HalfLineDash: UInt8 = 11
    public static let CODE_EmDash: UInt8 = 0x97
    
    // End codes (from makedeva.c)
    public static let CODE_EndVerseLine: UInt8 = 10
    public static let CODE_EndUvaca: UInt8 = 12
    public static let CODE_EndVerse: UInt8 = 13
    public static let CODE_EndProseLine: UInt8 = 14
    public static let CODE_EndProse: UInt8 = 15
    
    // Glyph code constants (from devaline.c lines 52-153)
    public static let xr__: UInt8 = 0x3B
    public static let F___: UInt8 = 0x7E
    public static let lha_: UInt8 = 0x80
    public static let kra_: UInt8 = 0x82
    public static let gr__: UInt8 = 0x83
    public static let Gr__: UInt8 = 0x84
    public static let cr__: UInt8 = 0x85
    public static let jr__: UInt8 = 0x86
    public static let tr__: UInt8 = 0x87
    public static let Tr__: UInt8 = 0x88
    public static let dra_: UInt8 = 0x89
    public static let Dr__: UInt8 = 0x8B
    public static let nr__: UInt8 = 0x8C
    public static let pr__: UInt8 = 0x91
    public static let Pra_: UInt8 = 0x92
    public static let br__: UInt8 = 0x93
    public static let Br__: UInt8 = 0x94
    public static let mr__: UInt8 = 0x95
    public static let vr__: UInt8 = 0x98
    public static let Zr__: UInt8 = 0x99
    public static let sr__: UInt8 = 0x9B
    public static let hra_: UInt8 = 0x9C
    public static let kSr_: UInt8 = 0x9F
    public static let kna_: UInt8 = 0xA1
    public static let gn__: UInt8 = 0xA2
    public static let Gn__: UInt8 = 0xA3
    public static let tn__: UInt8 = 0xA5
    public static let Tn__: UInt8 = 0xA7
    public static let dna_: UInt8 = 0xA8
    public static let Dn__: UInt8 = 0xA9
    public static let nn__: UInt8 = 0xAA
    public static let pn__: UInt8 = 0xAB
    public static let Pna_: UInt8 = 0xAC
    public static let bn__: UInt8 = 0xAE
    public static let Bn__: UInt8 = 0xAF
    public static let mn__: UInt8 = 0xB0
    public static let vn__: UInt8 = 0xB1
    public static let Zn__: UInt8 = 0xB4
    public static let sn__: UInt8 = 0xB5
    public static let hna_: UInt8 = 0xB6
    public static let kta_: UInt8 = 0xB7
    public static let kva_: UInt8 = 0xB8
    public static let kS__: UInt8 = 0xBA
    public static let cc__: UInt8 = 0xBB
    public static let cW__: UInt8 = 0xBF
    public static let jj__: UInt8 = 0xC0
    public static let jW__: UInt8 = 0xC1
    public static let Wc__: UInt8 = 0xC2
    public static let Wj__: UInt8 = 0xC3
    public static let qqa_: UInt8 = 0xC4
    public static let qva_: UInt8 = 0xC5
    public static let xka_: UInt8 = 0xC6
    public static let xku_: UInt8 = 0xC7
    public static let xkta: UInt8 = 0xC8
    public static let xkSa: UInt8 = 0xC9
    public static let xKa_: UInt8 = 0xCA
    public static let xga_: UInt8 = 0xCB
    public static let xgu_: UInt8 = 0xCC
    public static let xgra: UInt8 = 0xCD
    public static let xGa_: UInt8 = 0xCE
    public static let xxa_: UInt8 = 0xCF
    public static let xBa_: UInt8 = 0xD1
    public static let xva_: UInt8 = 0xD2
    public static let Xva_: UInt8 = 0xD3
    public static let tt__: UInt8 = 0xD4
    public static let dga_: UInt8 = 0xD5
    public static let dgu_: UInt8 = 0xD6
    public static let dgra: UInt8 = 0xD8
    public static let dGa_: UInt8 = 0xD9
    public static let dda_: UInt8 = 0xDA
    public static let ddra: UInt8 = 0xDB
    public static let dDa_: UInt8 = 0xDC
    public static let dba_: UInt8 = 0xDF
    public static let dBa_: UInt8 = 0xE0
    public static let dma_: UInt8 = 0xE1
    public static let dya_: UInt8 = 0xE2
    public static let dva_: UInt8 = 0xE3
    public static let d___: UInt8 = 0xE4
    public static let dr__: UInt8 = 0xE5
    public static let pt__: UInt8 = 0xE6
    public static let ru__: UInt8 = 0xE7
    public static let rU__: UInt8 = 0xE8
    public static let ll__: UInt8 = 0xE9
    public static let Zca_: UInt8 = 0xEA
    public static let Zla_: UInt8 = 0xEB
    public static let Zva_: UInt8 = 0xEC
    public static let Sqa_: UInt8 = 0xED
    public static let Sqva: UInt8 = 0xEE
    public static let SQa_: UInt8 = 0xEF
    public static let stra: UInt8 = 0xF1
    public static let hu__: UInt8 = 0xF2
    public static let hU__: UInt8 = 0xF3
    public static let hR__: UInt8 = 0xF4
    public static let hNa_: UInt8 = 0xF5
    public static let hma_: UInt8 = 0xF6
    public static let hya_: UInt8 = 0xF7
    public static let hla_: UInt8 = 0xF8
    public static let hva_: UInt8 = 0xF9
    public static let u_h_: UInt8 = 0xFA
    public static let U_h_: UInt8 = 0xFB
    public static let R_h_: UInt8 = 0xFC
    public static let f___: UInt8 = 0xFF
}
