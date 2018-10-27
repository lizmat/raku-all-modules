use Test;

plan 1;

eval_lives_ok 'use XXX; ', 'XXX modules loads without errors';
