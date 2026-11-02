# -*- coding: utf-8 -*-
"""
Phase 10: Business (200 words)
"""
try:
    from scripts.data_p10_business_p1 import P10_BUSINESS_WORDS_P1
    from scripts.data_p10_business_p2 import P10_BUSINESS_WORDS_P2
    from scripts.data_p10_business_p3 import P10_BUSINESS_WORDS_P3
    from scripts.data_p10_business_p4 import P10_BUSINESS_WORDS_P4
except ImportError:
    from data_p10_business_p1 import P10_BUSINESS_WORDS_P1
    from data_p10_business_p2 import P10_BUSINESS_WORDS_P2
    from data_p10_business_p3 import P10_BUSINESS_WORDS_P3
    from data_p10_business_p4 import P10_BUSINESS_WORDS_P4

P10_BUSINESS_WORDS = P10_BUSINESS_WORDS_P1 + P10_BUSINESS_WORDS_P2 + P10_BUSINESS_WORDS_P3 + P10_BUSINESS_WORDS_P4
