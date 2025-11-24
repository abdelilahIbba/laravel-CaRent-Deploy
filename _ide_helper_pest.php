<?php

/**
 * This file provides IDE autocomplete for Pest tests
 * @see https://pestphp.com/docs/ide-plugins
 */

namespace {
    /**
     * @template TValue
     * 
     * @param Closure(Tests\TestCase):TValue $closure
     * @return TValue
     */
    function test(string $description, ?Closure $closure = null) {}
    
    /**
     * @template TValue
     * 
     * @param Closure(Tests\TestCase):TValue $closure
     * @return TValue
     */
    function it(string $description, ?Closure $closure = null) {}
}
