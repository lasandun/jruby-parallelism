#!/usr/bin/jruby 
require 'thread'
include Java

def simpson(lowerBound, upperBound, samples, func)
    @proc = func

    def f(x)
        @proc.call(x)
    end

    if((samples/2)*2 != samples) 
        samples=samples+1;
    end
    s = 0.0
    dx = (upperBound-lowerBound)/(samples*1.0);
    i = 2
    while(i <= samples-1)
       x = lowerBound + i * dx
       s += 2.0*f(x) + 4.0*f(x+dx)
       i = i + 2
    end
    s = (s + f(lowerBound)+f(upperBound)+4.0*f(lowerBound+dx) )*dx/3.0;
    return s
end


# calls simpson() parallely in [lowerBound, upperBound] bracekts.
def simpsonParallel(lowerBound, upperBound, samples, proc1)
    noOfThreads = 1#java.lang.Runtime.getRuntime.availableProcessors
    puts "'#{noOfThreads}' threads has been created"
    samples = samples/noOfThreads     # calculate sample size for one thread
    chunkSize = 1.0*(upperBound - lowerBound)/noOfThreads
    sol = 0.0
	
    threadArr = Array.new(noOfThreads)
    
    for i in 0..(noOfThreads-1)  # spawn processes
        threadArr[i] = Thread.new(i){ |n|
            lb = lowerBound + chunkSize * n
            ub = lb + chunkSize
            subSol = simpson(lb, ub, samples, proc1)    # updating 'sol' is synchronized
            subSol
        }
    end

    threadArr.each {|t| t.join;}   #wait until all the subproblems are solved
    sol = threadArr.reduce(0) { |sum, thread| sum + thread.value }
    return sol
end



start = Time.now
var = simpsonParallel(0, 10, 80000000, proc{ |x| x*x*x*x-x*x+2*x} )
finish = Time.now
diff = finish - start
puts "result = #{var}"
puts "time = #{diff}"

