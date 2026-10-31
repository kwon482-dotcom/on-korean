# -*- coding: utf-8 -*-
"""
Phase 8: Business & Current Affairs (100 words)
"""
try:
    from scripts.data_p8_business_p1 import P8_BUSINESS_WORDS_P1
    from scripts.data_p8_business_p2 import P8_BUSINESS_WORDS_P2
except ImportError:
    from data_p8_business_p1 import P8_BUSINESS_WORDS_P1
    from data_p8_business_p2 import P8_BUSINESS_WORDS_P2

P8_BUSINESS_WORDS = P8_BUSINESS_WORDS_P1 + P8_BUSINESS_WORDS_P2
