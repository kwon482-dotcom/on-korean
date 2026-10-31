# -*- coding: utf-8 -*-
"""
Phase 7: Business & Current Affairs (100 words)
"""

try:
    from scripts.data_p7_business_p1 import P7_BUSINESS_WORDS_P1
    from scripts.data_p7_business_p2 import P7_BUSINESS_WORDS_P2
except ImportError:
    from data_p7_business_p1 import P7_BUSINESS_WORDS_P1
    from data_p7_business_p2 import P7_BUSINESS_WORDS_P2

P7_BUSINESS_WORDS = P7_BUSINESS_WORDS_P1 + P7_BUSINESS_WORDS_P2
