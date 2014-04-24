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
def simpsonParallel(lowerBound, upperBound, samples, proc1, noOfThreads)
    samples = samples/noOfThreads     # calculate sample size for one thread
    chunkSize = 1.0*(upperBound - lowerBound)/noOfThreads
    sol = 0.0
	
    threadArr = Array.new(noOfThreads)
    
    for i in 0..(noOfThreads-1)  # spawn processes
        threadArr[i] = Thread.new(i){ |n|
            lb = lowerBound + chunkSize * n
            ub = lb + chunkSize
            subSol = simpson(lb, ub, samples, proc1)
            subSol
        }
    end

    threadArr.each {|t| t.join;}   #wait until all the subproblems are solved
    sol = threadArr.reduce(0) { |sum, thread| sum + thread.value }
    return sol
end

def test(a, b, n, testProc, noOfThreads, filePath)
    start = Time.now
    var = simpsonParallel(a, b, n, testProc, noOfThreads)
    finish = Time.now
    diff = finish - start
    puts "threads: #{noOfThreads}     step size: #{n}    time: #{diff}\n"
    return diff
end

# iteratively do the testing
def performanceTest(maxThreads, maxSteps, filePath)
    File.open(filePath, "a") do |line|
        v = maxSteps / 5000000
        for threads in 1..(maxThreads)
            for k in 1..v
                steps = k * 5000000
                diff = test(0, 10, steps, proc{ |x| x*x*x*x-x*x+2*x+Math.log(x)+Math.sin(x)}, threads, filePath)
                line.write("#{threads} #{diff}\n") # update the file
            end
        end
    end
end

# use maxSteps > 5000000
performanceTest(8, 50000000, "/home/lahiru/performanceTest/out.txt")
