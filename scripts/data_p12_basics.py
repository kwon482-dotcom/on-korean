# -*- coding: utf-8 -*-
"""
Phase 12: Basics (100 words)
"""
try:
    from scripts.data_p12_basics_p1 import P12_BASICS_WORDS_P1
    from scripts.data_p12_basics_p2 import P12_BASICS_WORDS_P2
except ImportError:
    from data_p12_basics_p1 import P12_BASICS_WORDS_P1
    from data_p12_basics_p2 import P12_BASICS_WORDS_P2

P12_BASICS_WORDS = P12_BASICS_WORDS_P1 + P12_BASICS_WORDS_P2
