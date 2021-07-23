﻿#include <stdio.h>
#include<math.h>
#include <time.h>
#include "utils.h"
#include "cpu_imp.cuh"
#include "gpu_imp.cuh"

#define KERNEL_SIZE 3
#define KERNEL_RADIUS KERNEL_SIZE/2

#define GAUSSIAN_KERNEL_SIZE 7
#define GAUSSIAN_KERNEL_RADIUS GAUSSIAN_KERNEL_SIZE/2
#define SIGMA 1
#define LOW_THRESHOLD_RATIO 0.05
#define HIGH_THRESHOLD_RATIO 0.5
#define OUTPUT true

float sobel_kernel_3x3_h[3][3] = { {1, 0, -1}, {2, 0, -2}, {1, 0, -1} };
float sobel_kernel_3x3_v[3][3] = { {1, 2, 1}, {0, 0, 0}, {-1, -2, -1} };

float robert_kernel_3x3_h[3][3] = { {1, 0, 0}, {0, -1, 0}, {0, 0, 0} };
float robert_kernel_3x3_v[3][3] = { {0, 1, 0},{-1, 0, 0}, {0, 0, 0} };

float gaussian_kernel_7x7[7][7];

char filename[] = "A.jpg";

void print_device_props()
{
	printf("============================\n");
	printf("	Device info	\n");
	printf("============================\n\n");
	cudaDeviceProp prop;
	cudaGetDeviceProperties(&prop, 0);
	printf("Device name: %s\n", prop.name);
	printf("Memory Clock Rate (KHz): %d\n",
		prop.memoryClockRate);
	printf("Memory Bus Width (bits): %d\n",
		prop.memoryBusWidth);
	printf("Peak Memory Bandwidth (GB/s): %f\n\n",
		2.0*prop.memoryClockRate*(prop.memoryBusWidth / 8) / 1.0e6);
}

int main()
{
	print_device_props();

	if (!check_input(filename))
		return 0;
	print_file_details(filename);

	printf("============================\n");
	printf("	CPU Convolution(Robert)	\n");
	printf("============================\n\n");
	filter_cpu(filename, "Sample_Robert.png", &robert_kernel_3x3_h[0][0], KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);

	load_constant_memory_robert_h(&robert_kernel_3x3_h[0][0], KERNEL_SIZE);
	load_constant_memory_robert_v(&robert_kernel_3x3_v[0][0], KERNEL_SIZE);

	load_constant_memory_sobel_h(&sobel_kernel_3x3_h[0][0], KERNEL_SIZE);
	load_constant_memory_sobel_v(&sobel_kernel_3x3_v[0][0], KERNEL_SIZE);

	/*printf("============================\n");
	printf("	GPU Convolution(Robert) - Parallel	\n");
	printf("============================\n\n");

	naive_robert_convolution_gpu(filename, KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);

	printf("============================\n");
	printf("	GPU Convolution(Robert) - Smem	\n");
	printf("============================\n\n");

	smem_robert_convolution_gpu(filename, KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);

	printf("============================\n");
	printf("	GPU Convolution(Robert) - Streams	\n");
	printf("============================\n\n");

	stream_robert_convolution_gpu(filename, KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);

	printf("============================\n");
	printf("	CPU Module(Sobel)\n");
	printf("============================\n\n");

	module_cpu(filename, "Sample_Module_Sobel.png", &sobel_kernel_3x3_h[0][0], &sobel_kernel_3x3_v[0][0], KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);

	printf("============================\n");
	printf("	GPU Module(Sobel) - Parallel \n");
	printf("============================\n\n");

	naive_sobel_module_gpu(filename, KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);

	printf("============================\n");
	printf("	GPU Module(Sobel) - Smem	\n");
	printf("============================\n\n");

	smem_sobel_module_gpu(filename, KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);

	printf("============================\n");
	printf("	GPU Module(Sobel) - Streams	\n");
	printf("============================\n\n");

	stream_sobel_module_gpu(filename, KERNEL_SIZE, KERNEL_RADIUS, OUTPUT);
	*/
	calculate_gaussian_kernel(&gaussian_kernel_7x7[0][0], SIGMA, GAUSSIAN_KERNEL_SIZE, GAUSSIAN_KERNEL_RADIUS);
	load_constant_memory_gaussian(&gaussian_kernel_7x7[0][0], GAUSSIAN_KERNEL_SIZE);
	
	printf("============================\n");
	printf("	CPU Canny Filter \n");
	printf("============================\n\n");

	canny_cpu(filename, "Sample_Canny.png", &sobel_kernel_3x3_h[0][0], &sobel_kernel_3x3_v[0][0], &gaussian_kernel_7x7[0][0], SIGMA, GAUSSIAN_KERNEL_SIZE, GAUSSIAN_KERNEL_RADIUS, LOW_THRESHOLD_RATIO, HIGH_THRESHOLD_RATIO, OUTPUT);

	printf("============================\n");
	printf("	GPU Canny Filter - Parallel	\n");
	printf("============================\n\n");

	naive_canny_gpu(filename, SIGMA, GAUSSIAN_KERNEL_SIZE, GAUSSIAN_KERNEL_RADIUS, LOW_THRESHOLD_RATIO, HIGH_THRESHOLD_RATIO, OUTPUT);

	printf("============================\n");
	printf("	GPU Canny Filter - Smem	\n");
	printf("============================\n\n");

	smem_canny_gpu(filename, SIGMA, GAUSSIAN_KERNEL_SIZE, GAUSSIAN_KERNEL_RADIUS, LOW_THRESHOLD_RATIO, HIGH_THRESHOLD_RATIO, OUTPUT);

	return 0;
}

