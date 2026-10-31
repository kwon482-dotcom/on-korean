# -*- coding: utf-8 -*-
"""
Phase 7: Basics (100 words)
"""

try:
    from scripts.data_p7_basics_p1 import P7_BASICS_WORDS_P1
    from scripts.data_p7_basics_p2 import P7_BASICS_WORDS_P2
except ImportError:
    from data_p7_basics_p1 import P7_BASICS_WORDS_P1
    from data_p7_basics_p2 import P7_BASICS_WORDS_P2

P7_BASICS_WORDS = P7_BASICS_WORDS_P1 + P7_BASICS_WORDS_P2
