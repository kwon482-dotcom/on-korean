# -*- coding: utf-8 -*-
"""
Phase 12: Business (100 words)
"""
try:
    from scripts.data_p12_business_p1 import P12_BUSINESS_WORDS_P1
    from scripts.data_p12_business_p2 import P12_BUSINESS_WORDS_P2
except ImportError:
    from data_p12_business_p1 import P12_BUSINESS_WORDS_P1
    from data_p12_business_p2 import P12_BUSINESS_WORDS_P2

P12_BUSINESS_WORDS = P12_BUSINESS_WORDS_P1 + P12_BUSINESS_WORDS_P2
