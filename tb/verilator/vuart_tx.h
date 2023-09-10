#pragma once

#include <stdio.h>
#include <stdint.h>
#include <verilated_vcd_c.h>

template <class VA> class TESTB {
public:
    VA *m_core;
    VerilatedVcdC *m_trace;
    uint64_t m_tickcount;

    TESTB(void) {
        m_core = new VA;
        Verilated::traceEverOn(true);
        m_trace = NULL;
        m_tickcount = 0;
        m_core->clk = 0;
        eval();
    }

    ~TESTB(void) {
        closetrace();
        delete this->m_core;
        this->m_core = NULL;
    }
    
    void opentrace(const char *vcdname) {
        if (this->m_trace == NULL) {
            this->m_trace = new VerilatedVcdC;
            this->m_core->trace(this->m_trace, 99);
            this->m_trace->open(vcdname);
        }
    }

    void closetrace(void) {
        if (this->m_trace) {
            this->m_trace->close();
            delete this->m_trace;
            this->m_trace = NULL;
        }
    }
    
    void eval(void) {
        this->m_core->eval();
    }

    void tick(void) {
        this->m_tickcount++;
        eval();
        if (this->m_trace) {
            this->m_trace->dump((vluint64_t)(10 * this->m_tickcount - 2));
        }
        this->m_core->clk = 1;
        eval();

        if (this->m_trace) {
            this->m_trace->dump((vluint64_t)(10 * this->m_tickcount));
        }
        this->m_core->clk = 0;
        eval();
        if (this->m_trace) {
            this->m_trace->dump((vluint64_t)(10 * this->m_tickcount + 5));
            this->m_trace->flush();
        }
    }

    void reset(void) {
        this->m_core->resetn = 0;
        eval();
        tick();
        tick();
        tick();
        this->m_core->resetn = 1;
        eval();
    }
};
