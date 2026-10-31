# -*- coding: utf-8 -*-
"""
Phase 7: K-Drama & Colloquial (100 words)
"""

try:
    from scripts.data_p7_kdrama_p1 import P7_KDRAMA_WORDS_P1
    from scripts.data_p7_kdrama_p2 import P7_KDRAMA_WORDS_P2
except ImportError:
    from data_p7_kdrama_p1 import P7_KDRAMA_WORDS_P1
    from data_p7_kdrama_p2 import P7_KDRAMA_WORDS_P2

P7_KDRAMA_WORDS = P7_KDRAMA_WORDS_P1 + P7_KDRAMA_WORDS_P2
