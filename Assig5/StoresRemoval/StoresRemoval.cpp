//===- StoresRemoval.cpp - Example code from "Writing an LLVM Pass" ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements two versions of the LLVM "StoresRemoval World" pass described
// in docs/WritingAnLLVMPass.html
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/Statistic.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "storesremoval"

STATISTIC(StoresRemovalCounter, "Counts number of functions greeted");

namespace {
  // StoresRemoval - The first implementation, without getAnalysisUsage.
  struct StoresRemoval : public BasicBlockPass {
    static char ID; // Pass identification, replacement for typeid
    StoresRemoval() : BasicBlockPass(ID) {}

    bool runOnBasicBlock(BasicBlock &F) override {
      ++StoresRemovalCounter;
      errs() << "MyStoresRemoval: ";
      errs().write_escaped(F.getName()) << '\n';
      return false;
    }
  };
}

char StoresRemoval::ID = 0;
static RegisterPass<StoresRemoval> X("storesremoval", "StoresRemoval World Pass");

namespace {
  // StoresRemoval2 - The second implementation with getAnalysisUsage implemented.
  struct StoresRemoval2 : public BasicBlockPass {
    static char ID; // Pass identification, replacement for typeid
    StoresRemoval2() : BasicBlockPass(ID) {}

    bool runOnBasicBlock(BasicBlock &F) override {
      ++StoresRemovalCounter;
      errs() << "StoresRemoval: ";
      errs().write_escaped(F.getName()) << '\n';
      return false;
    }

    // We don't modify the program, so we preserve all analyses.
    void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.setPreservesAll();
    }
  };
}

char StoresRemoval2::ID = 0;
static RegisterPass<StoresRemoval2>
Y("storesremoval2", "StoresRemoval World Pass (with getAnalysisUsage implemented)");
