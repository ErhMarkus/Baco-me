#ifndef KERNEL
#define KERNEL

//////////////////////////////////////////////////////////
A lattice Boltzmann fluid flow solver written using CUDA
Code adapted from Bruce Jones LBM-C by Erhardt Markus
////////////////////////////////////////////////////////////////////////////////
//
// D2Q9 Lattice configuration:
//
//       6   2   5
//        \  |  /
//         \ | /
//          \|/
//       3---0---1
//          /|\
//         / | \
//        /  |  \
//       7   4   8
//
///////////////////////////////////////////////////////////////////////////////


#include <stdio.h>
#include "./data_types.cuh"
#include "./macros.cu"
#include "./solver.cu"
#include "./prepareCuda.cuh"
#include "model_builder.cu"
#include "cuda_util.cu"

// Include THRUST libraries
#include <thrust/transform_reduce.h>
#include <thrust/for_each.h>
#include <thrust/iterator/zip_iterator.h>
#include <thrust/device_vector.h>

// DEVICE VARIABLE DECLARATION
Lattice *lattice_device;
Domain *domain_device;
DomainConstant *domain_constants_device;
OutputController *output_controller_device;

// HOST VARIABLE DECLARATION
Lattice *lattice_host, *lattice_device_prototype;
Domain *domain_host;
DomainConstant *domain_constants_host;
OutputController *output_controller_host;
Timing *times;
ProjectStrings *project;
ModelBuilder model_builder;



// EXECUTES ALL ROUTINES REQUIRED FOR THE MODEL SET UP

void setup(char *data_file)
{
	// Set cuda device to use
	cudaSetDevice(0);
	cudaFuncSetCacheConfig(iterate_kernel, cudaFuncCachePreferL1);
	
	// Allocate container structures

	combi_malloc<Lattice>(&latsetuptice_host, &lattice_device, sizeof(Lattice)); //combi_malloc (T **host_pointer, T **device_pointer, size_t size) into cuda_util.cu
	combi_malloc<Domain>(&domain_host, &domain_device, sizeof(Domain));
	combi_malloc<DomainConstant>(&domain_constants_host, &domain_constants_device, sizeof(DomainConstant));
	combi_malloc<OutputController>(&output_controller_host, &output_controller_device, sizeof(OutputController));
	domain_constants_host = (DomainConstant *)malloc(sizeof(DomainConstant));
	times = (Timing *)malloc(sizeof(Timing));
	project = (ProjectStrings *)malloc(sizeof(ProjectStrings));
	lattice_device_prototype = (Lattice *)malloc(sizeof(Lattice));

	ModelBuilder tmpmb(data_file, lattice_host, lattice_device,
		domain_constants_host, domain_constants_device,
		domain_host, domain_device,
		output_controller_host, output_controller_device,
		times, project);
	model_builder = tmpmb;

	int z_len = 1;
	#if DIM > 2
		z_len = domain_constants_host->length[2];
	#endif
}





