package Perluno;
require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

bootstrap Perluno;

@EXPORT = qw( createComponentContext );

1;
