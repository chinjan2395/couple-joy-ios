//
//  PartnerRole.swift
//  Couple Joy
//
//  Created by Chinjan Patel on 10/05/25.
//

import Foundation

enum PartnerRole: String, Codable {
    case partnerA
    case partnerB

    var owner: PartnerRole {
        return self
    }

    var opposite: PartnerRole {
        return self == .partnerA ? .partnerB : .partnerA
    }

    var displayName: String {
        switch self {
        case .partnerA: return "Partner A"
        case .partnerB: return " B"
        }
    }
    
    var shortLabel: String {
        switch self {
        case .partnerA: return "A"
        case .partnerB: return "B"
        }
    }
}
