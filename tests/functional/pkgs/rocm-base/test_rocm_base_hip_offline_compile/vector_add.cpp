#include <hip/hip_runtime.h>

#include <cstdio>
#include <vector>

#define HIP_CHECK(expr) do {                                      \
    hipError_t error = (expr);                                    \
    if (error != hipSuccess) {                                    \
        std::fprintf(stderr, "%s\n", hipGetErrorString(error)); \
        return 1;                                                  \
    }                                                             \
} while (0)

__global__ void add(const int *a, const int *b, int *c, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

int main()
{
    int count = 0;
    HIP_CHECK(hipGetDeviceCount(&count));
    if (count != 1) {
        std::fprintf(stderr, "expected 1 GPU, got %d\n", count);
        return 2;
    }

    hipDeviceProp_t properties{};
    HIP_CHECK(hipGetDeviceProperties(&properties, 0));
    std::printf("device=%s arch=%s\n", properties.name, properties.gcnArchName);

    constexpr int size = 4096;
    std::vector<int> a(size), b(size), c(size);
    for (int i = 0; i < size; ++i) {
        a[i] = i;
        b[i] = i * 2;
    }

    int *device_a = nullptr;
    int *device_b = nullptr;
    int *device_c = nullptr;
    HIP_CHECK(hipMalloc(reinterpret_cast<void **>(&device_a), size * sizeof(int)));
    HIP_CHECK(hipMalloc(reinterpret_cast<void **>(&device_b), size * sizeof(int)));
    HIP_CHECK(hipMalloc(reinterpret_cast<void **>(&device_c), size * sizeof(int)));
    HIP_CHECK(hipMemcpy(device_a, a.data(), size * sizeof(int), hipMemcpyHostToDevice));
    HIP_CHECK(hipMemcpy(device_b, b.data(), size * sizeof(int), hipMemcpyHostToDevice));

    hipLaunchKernelGGL(add, dim3((size + 255) / 256), dim3(256), 0, 0,
                       device_a, device_b, device_c, size);
    HIP_CHECK(hipGetLastError());
    HIP_CHECK(hipDeviceSynchronize());
    HIP_CHECK(hipMemcpy(c.data(), device_c, size * sizeof(int), hipMemcpyDeviceToHost));

    for (int i = 0; i < size; ++i) {
        if (c[i] != i * 3) {
            std::fprintf(stderr, "mismatch at %d: %d\n", i, c[i]);
            return 3;
        }
    }

    HIP_CHECK(hipFree(device_a));
    HIP_CHECK(hipFree(device_b));
    HIP_CHECK(hipFree(device_c));
    std::puts("HIP vector add: PASS");
    return 0;
}
