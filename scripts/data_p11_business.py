# -*- coding: utf-8 -*-
"""
Phase 11: Business (100 words)
"""
try:
    from scripts.data_p11_business_p1 import P11_BUSINESS_WORDS_P1
    from scripts.data_p11_business_p2 import P11_BUSINESS_WORDS_P2
except ImportError:
    from data_p11_business_p1 import P11_BUSINESS_WORDS_P1
    from data_p11_business_p2 import P11_BUSINESS_WORDS_P2

P11_BUSINESS_WORDS = P11_BUSINESS_WORDS_P1 + P11_BUSINESS_WORDS_P2
