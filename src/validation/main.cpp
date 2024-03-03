#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cstdio>
#include <filesystem>

#define CRYPTOPP_ENABLE_NAMESPACE_WEAK 1
#include "./cryptopp/cryptlib.h"
#include "./cryptopp/filters.h"
#include "./cryptopp/files.h"
#include "./cryptopp/hex.h"
#include "./cryptopp/md5.h"
#include "./cryptopp/sha.h"

struct f_entry {
  std::string f_name;
  std::string md5_digest;
  std::string sha_digest;
};

std::vector<std::string> parse_data_store(std::string filename);
std::vector<f_entry> parse_lines(std::vector<std::string> lines);
void prune_invalid_entries(std::vector<f_entry>& entries);

f_entry parse_entry(const std::string& line);
bool validate_entry(const f_entry& entry);
bool entry_exists(const f_entry& entry);

// dependency injection candidates
std::string generate_md5(const std::string filename);
std::string generate_sha(const std::string filename);
bool compare_md5(const f_entry& entry);
bool compare_sha(const f_entry& entry);

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cout << "usage: " << argv[0] << " [filename]" << std::endl;
    return 1;
  }

  auto data {parse_data_store(std::string(argv[1]))};
  auto entries {parse_lines(data)};

  prune_invalid_entries(entries);

  auto res = std::ranges::all_of(entries, validate_entry);
  std::cout << res << std::endl;
  return 0;
}

std::string generate_md5(std::string filename) {
  static CryptoPP::Weak::MD5 hash;
  std::string res;
  CryptoPP::FileSource file(filename.c_str(), true, 
                            new CryptoPP::HashFilter(
                              hash, 
                              new CryptoPP::HexEncoder(
                                new CryptoPP::StringSink(res), false
                              )
                            )
  );
  return res;
}

std::string generate_sha(std::string filename) {
  static CryptoPP::SHA256 hash;
  std::string res;
  CryptoPP::FileSource file(filename.c_str(), true, 
                            new CryptoPP::HashFilter(
                              hash, 
                              new CryptoPP::HexEncoder(
                                new CryptoPP::StringSink(res), false
                              )
                            )
  );
  return res;

}

bool compare_md5(const f_entry& entry) {
  return entry.md5_digest == generate_md5(entry.f_name);
}

bool compare_sha(const f_entry& entry) {
  return entry.sha_digest == generate_sha(entry.f_name);
}

std::vector<std::string> parse_data_store(std::string filename) {
  std::vector<std::string> lines;
  std::fstream fs(filename);
  if (!fs.is_open())
    return lines;
  std::string line;
  while (std::getline(fs, line))
    lines.push_back(line);
  return lines;
}

std::vector<f_entry> parse_lines(std::vector<std::string> lines) {
  std::vector<f_entry> res;
  std::ranges::transform(lines, std::back_inserter(res), parse_entry);
  return res;
}

bool entry_exists(const f_entry& entry) {
  namespace fs = std::filesystem;
  auto cwd = fs::current_path();
  return fs::exists(cwd/entry.f_name);
}

f_entry parse_entry(const std::string& line) {
  std::stringstream ss;
  f_entry e;
  ss << line;
  ss >> e.f_name >> e.md5_digest >> e.sha_digest;
  return e;
}

bool validate_entry(const f_entry& entry) {
  if (!entry_exists(entry)) return false;
  return (compare_md5(entry) && compare_sha(entry));
}

void prune_invalid_entries(std::vector<f_entry>& entries) {
  entries.erase(
    std::remove_if(
      entries.begin(), 
      entries.end(), 
      [](auto entry){return !(entry_exists(entry));}), 
    entries.end()
  );
}
