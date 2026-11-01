# -*- coding: utf-8 -*-
"""
Phase 9: 비즈니스 & 시사 고급 한국어 (200 words)
"""
try:
    from scripts.data_p9_business_p1 import P9_BUSINESS_WORDS_P1
    from scripts.data_p9_business_p2 import P9_BUSINESS_WORDS_P2
    from scripts.data_p9_business_p3 import P9_BUSINESS_WORDS_P3
    from scripts.data_p9_business_p4 import P9_BUSINESS_WORDS_P4
except ImportError:
    from data_p9_business_p1 import P9_BUSINESS_WORDS_P1
    from data_p9_business_p2 import P9_BUSINESS_WORDS_P2
    from data_p9_business_p3 import P9_BUSINESS_WORDS_P3
    from data_p9_business_p4 import P9_BUSINESS_WORDS_P4

P9_BUSINESS_WORDS = P9_BUSINESS_WORDS_P1 + P9_BUSINESS_WORDS_P2 + P9_BUSINESS_WORDS_P3 + P9_BUSINESS_WORDS_P4
