#include <iostream>
#include <fstream>
#include <cstdio>
#include <filesystem>
#include <algorithm>
#include <chrono>
#include <vector>

constexpr unsigned int MAX_AGE_IN_SECONDS { 60 * 60 * 24 * 30 };

void purge_old_files(void);
void rewrite_data_store(std::string filename);

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cout << "usage: " << argv[0] << " [integrity file]";
    return 1;
  }
  
  purge_old_files();
  rewrite_data_store(std::string(argv[1]));
  return 0;
}

void purge_old_files(void) {
  namespace fs = std::filesystem;
  std::vector<fs::path> archives;
  for (auto filename : fs::directory_iterator(fs::current_path())) {
    if (filename.path().has_extension() && filename.path().extension() == ".7z")
      archives.push_back(filename.path());
  }
  auto current_time {std::chrono::system_clock::now()};
  auto current_timestamp {std::chrono::duration_cast<std::chrono::seconds>(current_time.time_since_epoch()).count()};
  for (auto filename : archives) {
    std::string timestamp_string {filename.filename().string().substr(0, filename.filename().string().find('-'))};
    unsigned long timestamp_int {std::stoul(timestamp_string)};


    if (current_timestamp - timestamp_int > MAX_AGE_IN_SECONDS) {
      fs::remove(filename);
    }
  }
}

void rewrite_data_store(std::string filename) {
  std::fstream fs(filename);
  if (!fs.is_open()) {
    std::cerr << "ERR: Could not open integrity file (Check the exact filename)" << std::endl;
    return;
  }
  std::string line;
  std::vector<std::string> lines;
  while (std::getline(fs, line)) 
    lines.push_back(line);
  
  auto invalid_file = [](std::string line){
    line = std::filesystem::current_path() / line.substr(0, line.find(' '));
    FILE* fp = std::fopen(line.c_str(), "r");
    if (fp) {
      std::fclose(fp);
      return false;
    }
    return true;
  };

  lines.erase(std::remove_if(lines.begin(), lines.end(), invalid_file), lines.end());

  fs.close();
  fs.open(filename, std::ios::out);
  for (auto line : lines) {
    fs << line << '\n';
  }

  fs.close();
}
