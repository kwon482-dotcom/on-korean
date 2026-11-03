# -*- coding: utf-8 -*-
"""
Phase 11: Kdrama (100 words)
"""
try:
    from scripts.data_p11_kdrama_p1 import P11_KDRAMA_WORDS_P1
    from scripts.data_p11_kdrama_p2 import P11_KDRAMA_WORDS_P2
except ImportError:
    from data_p11_kdrama_p1 import P11_KDRAMA_WORDS_P1
    from data_p11_kdrama_p2 import P11_KDRAMA_WORDS_P2

P11_KDRAMA_WORDS = P11_KDRAMA_WORDS_P1 + P11_KDRAMA_WORDS_P2
