# -*- coding: utf-8 -*-
"""
Phase 8: K-Drama & Colloquial (100 words)
"""

try:
    from scripts.data_p8_kdrama_p1 import P8_KDRAMA_WORDS_P1
    from scripts.data_p8_kdrama_p2 import P8_KDRAMA_WORDS_P2
except ImportError:
    from data_p8_kdrama_p1 import P8_KDRAMA_WORDS_P1
    from data_p8_kdrama_p2 import P8_KDRAMA_WORDS_P2

P8_KDRAMA_WORDS = P8_KDRAMA_WORDS_P1 + P8_KDRAMA_WORDS_P2
