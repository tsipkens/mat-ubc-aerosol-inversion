# mat-2d-aerosol-inversion

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

A program to invert CPMA-DMA data to find the two-dimensional
mass-mobility distribution associated with [Sipkens et al. (Submitted)][1].

This program is organized into several packages and classes.


### Scripts in upper directory

###### `main*.m` scripts

The `main*.m` scripts in the top directory of the code can be called to
demonstrate use of the code. Scripts to execute this program should be
structured as follows:

1. Optionally, one can define a phantom used to generate synthetic data and a
ground truth. The `@Phantom` class, described below, is designed to
perform this task. The results is an instance of the `@Grid` class, which is
also described below, and a vector, `x_t`, that contains a vectorized form of
the phantom distribution.

2. One must now generate a model matrix, `A`, which relates the distribution,
`x`, to the data, `b`, such that **Ax** = **b**. This requires information of
both the transfer functions involved as well as the grids on which `x` and `b`
are defined. For phantom distributions, the grid for `x` can generated using
the `@Phantom` class. In all other cases, the grid for `x` and `b` can be
generated by creating an instance of the `@Grid` class described below.

3. Next, one must define some set of data in an appropriate format. For
simulated data, this is straightforward: `b = A*x;`. For experimental data, one
must have defined a grid for the data as part of Step 2, and then the data
should be imported and vectorized to match that grid. Also in this step, one
should also include some definition of the expected uncertainties in each point
in `b`, encoded in the matrix `Lb`. For those cases involving counting noise,
this can be approximated as `Lb = theta*diag(sqrt(b));`, where `theta` is
related to the total number of particle counts.

4. With this information, one can proceed to implement various inversion
approaches, such as those available in the `+invert` package described below.

5. Finally, one can post-process and visualize the results as desired. The
`@Grid` class allows for a simple visualization of the inferred distribution
by calling the `plot2d_marg` method of this class. This plots both the
retrieved distribution as well as the marginalized distribution on each of
the axes.

A description of the classes and packages that are included to perform these
tasks are included below.

##### `run_inversions*.m` scripts

These scripts are intend to bundle a series of inversion methods into a single
line of codd in the `main*.m` scripts. This can include optimization routines,
included in the `+invert` package, which run through several values of the
regularization parameters.

### Classes

###### @Grid

Grid is a class developed to discretize mass-mobility space. This is
done using a simple rectangular grid that can have linear, logarithmic
or custom spaced elements along the edges.

###### @Phantom

Phantom is a class developed to contain the parameters and other information
for the phantom distributions that are used in testing the different inversion
methods. Currently the phantom class is programmed to produce joint-normal
or joint-lognormal mass-mobiltiy distributons. The four sample phantoms from
[Sipkens et al. (Submitted)][1] can be called using strings encompassing the
distribution numbers from that work (e.g. the demonstration phantom can be
generated using `'1'`.


#### Packages

###### +invert

Contains various functions used to invert the measured data for the desired
two-dimensional distribution. This includes implementations of least-squares,
Tikhonov regularization, Twomey, Twomey-Markowski (including using the method
of [Buckley et al. (2017)][3]), and the multiplicative algebraic reconstruction
technique (MART). Also included are functions that, given the true distribution,
can determine the optimal number of iterations or the optimal regularization
parameter. Development is underyway on the use of an exponential covariance
function to correlate pixel values and reduce reconstruction errors.

###### +tfer_PMA

This is imported from a package distributed with [Sipkens et al. (Accepted)][2].
This package is used in evaluating the transfer function of the particle mass
analyzers (PMAs), such as the aerosol particle mass analyzer (APM) and centrifugal
particle mass analyzer (CPMA). The package also contains some standard reference
functions used in `tfer_DMA.m`. The corresponding repository can be found at
[https://github.com/tsipkens/mat-tfer-pma](https://github.com/tsipkens/mat-tfer-pma).

###### +kernel

This package is used to evaluate the transfer function of the DMA and
particle mass analyzer (such as the CPMA or APM). The primary function
within the larger program is to generate a matrix `A` that acts as the
forward model. This package references the `+tfer_PMA` package, noted
above.

###### +tools

A series of utility functions that serve various purposes, including printing
a text-based progress bar (based on code from
[Samuel Grauer](https://www.researchgate.net/profile/Samuel_Grauer))
and a function to convert mass-mobility distributions to effective
density-mobility distributions.

----------------------------------------------------------------------

#### License

This software is licensed under an MIT license (see the corresponding file
for details).


#### Contact information and acknowledgements

This program was largely written and compiled by Timothy Sipkens
([tsipkens@mail.ubc.ca](mailto:tsipkens@mail.ubc.ca)) while at the
University of British Columbia.

This distribution includes code snippets from the code provided with
the work of [Buckley et al. (2017)][3],
who used a Twomey-type approach to derive two-dimensional mass-mobility
distributions. Much of the code from that work has been significantly
modified in this distribution.

Also included is a reference to code designed to quickly evaluate
the transfer function of particle mass analyzers (e.g. APM, CPMA) by
Sipkens et al. (Accepted).

Information on the provided colormaps can be found in an associated
README in the `cmap` folder.

#### References

1. [Sipkens et al., J. Aerosol Sci. (Submitted)][1]
2. [Sipkens et al., Aerosol Sci. Technol. (Accepted)][2]
3. [Buckley et al., J. Aerosol Sci. (2017)][3]

[1]: N/A
[2]: N/A
[3]: https://doi.org/10.1016/j.jaerosci.2017.09.012
