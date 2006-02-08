package Perluno;
require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT = qw( createComponentContext );

bootstrap Perluno;

1;
