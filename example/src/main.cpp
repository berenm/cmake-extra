import zlib;

#include <cstdint>

int main(int argc, char** argv) {
  uint8_t input[10] = {};
  uint64_t outsize = 0;
  uint8_t output[10] = {};
  zlib::uncompress(output, &outsize, input, 0);
  return 0;
}
