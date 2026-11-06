# -*- coding: utf-8 -*-
"""
Phase 12: Kdrama (100 words)
"""
try:
    from scripts.data_p12_kdrama_p1 import P12_KDRAMA_WORDS_P1
    from scripts.data_p12_kdrama_p2 import P12_KDRAMA_WORDS_P2
except ImportError:
    from data_p12_kdrama_p1 import P12_KDRAMA_WORDS_P1
    from data_p12_kdrama_p2 import P12_KDRAMA_WORDS_P2

P12_KDRAMA_WORDS = P12_KDRAMA_WORDS_P1 + P12_KDRAMA_WORDS_P2
