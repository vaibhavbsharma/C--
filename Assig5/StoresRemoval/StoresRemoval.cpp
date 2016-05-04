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
#include "llvm/IR/Instructions.h"

#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Transforms/Utils/Local.h"

#include "llvm/ADT/StringRef.h"

using namespace llvm;

#include <vector>
using namespace std;

#define DEBUG_TYPE "storesremoval"

STATISTIC(DIEEliminated, "Number of insts removed by DIE pass");

namespace {
  // StoresRemoval - The first implementation, without getAnalysisUsage.
  struct StoresRemoval : public BasicBlockPass {
    static char ID; // Pass identification, replacement for typeid
    StoresRemoval() : BasicBlockPass(ID) {}

    bool runOnBasicBlock(BasicBlock &F) override {
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

    bool runOnBasicBlock(BasicBlock &blk) override {
      auto *TLIP = getAnalysisIfAvailable<TargetLibraryInfoWrapperPass>();
      TargetLibraryInfo *TLI = TLIP ? &TLIP->getTLI() : nullptr;
      //errs() << "StoresRemoval: ";
      //errs().write_escaped(blk.getName()) << '\n';

      bool Changed = false;
      // blk is a pointer to a BasicBlock instance
      //for (BasicBlock::iterator i = blk.begin(), e = blk.end(); i != e; ++i)
	// The next statement works since operator<<(ostream&,...)
	// is overloaded for Instruction&
	//errs() << *i << "\n";
      vector<StringRef> names;
      for (BasicBlock::iterator DI = blk.begin(); DI != blk.end(); ) {
        Instruction *Inst = &*DI++;
        //errs() << *Inst << "  :  ";
        if (Inst->getOpcode() == Instruction::Store)  { 
          //errs()<<"store instruction operands: ";
          //errs() << *Inst << "  :  ";
          int count=0;
          for (Use &U: Inst->operands()) {
            StringRef str = (*U.get()).getName();
            if(str.str().length() == 0) continue;
            //errs() << count++<<" _"<< str <<"_ - ";
            /*for(int i=0;i<names.size();i++) 
              if(names[i].equals(str)) 
                errs() << "already seen : "<<names[i]<<" : ";*/
            //errs() << "__";
            names.push_back(str);
          } 
        }
        //errs() << "\n";
        //if (isInstructionTriviallyDead(Inst, TLI)) {
        //  errs() << "found trivial instruction!" << "\n";
        //  Inst->eraseFromParent();
        //  Changed = true;
        //  ++DIEEliminated;
        //}
      }
      for (BasicBlock::iterator DI = blk.begin(); DI != blk.end(); ) {
        Instruction *Inst = &*DI++;
        if (Inst->getOpcode() == Instruction::Store)  { 
          for (Use &U: Inst->operands()) {
            StringRef str = (*U.get()).getName();
            if(str.str().length() == 0) continue;
            int count=0;
            int index_first_occurence=-1;
            for(int i=0;i<names.size();i++) {
              if(names[i].equals(str)) { 
                count++;
                if(count==1) index_first_occurence=i;
              }
            }
            if(count > 1) {
              errs() << "Erasing "<<*Inst << "\n";
              Inst->eraseFromParent();
              names.erase(names.begin()+index_first_occurence);
              Changed=true;
              ++DIEEliminated;
            }
          }
        }
      }
      return Changed;
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
