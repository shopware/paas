<?php declare(strict_types=1);

namespace Shopware\Production;

class HttpKernel extends \Shopware\Core\HttpKernel
{
    protected static string $kernelClass = Kernel::class;
}
