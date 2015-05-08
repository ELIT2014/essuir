package ua.edu.sumdu.essuir.controllers;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.support.RequestContextUtils;
import ua.edu.sumdu.essuir.EssuirStatistics;
import ua.edu.sumdu.essuir.YearStatistics;
import ua.edu.sumdu.essuir.service.GeneralStatisticsService;
import ua.edu.sumdu.essuir.StatisticData;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

@Controller
@RequestMapping(value = "/stat")
public class TotalStatisticsController {

    @Autowired
    private GeneralStatisticsService generalStatisticsService;

    private static Logger log = Logger.getLogger(TotalStatisticsController.class);

    @RequestMapping(value = "/current", method = RequestMethod.GET)
    @ResponseBody
    public Map<String,Long> getTotalStatistics(HttpServletRequest request){
        Map<String,Long> stat = new HashMap<String, Long>();
        StatisticData sd;
        ArrayList<YearStatistics> listYearsStatistics= (ArrayList<YearStatistics>) generalStatisticsService.getListYearsStatistics();
        try {
            org.dspace.core.Context context = org.dspace.app.webui.util.UIUtil.obtainContext(request);
            sd = EssuirStatistics.getTotalStatistic(context);
            stat.put("TotalCount",sd.getTotalCount());
            stat.put("TotalViews", sd.getTotalViews());
            stat.put("TotalDownloads",sd.getTotalDownloads());
            stat.put("CurrentMonthStatisticsViews",getCurrentMonthStatisticsViews(listYearsStatistics, sd.getTotalViews()));
            stat.put("CurrentMonthStatisticsDownloads",getCurrentMonthStatisticsDownloads(listYearsStatistics, sd.getTotalDownloads()));
            stat.put("CurrentYearStatisticsViews",getCurrentYearStatisticsViews(listYearsStatistics, sd.getTotalViews()));
            stat.put("CurrentYearStatisticsDownloads",getCurrentYearStatisticsDownloads(listYearsStatistics, sd.getTotalDownloads()));
            context.complete();
        }catch (Exception ex) {
            log.error(ex.getMessage(), ex);
        }
        return stat;
    }

    @RequestMapping( value = "/pubstat", method = RequestMethod.GET)
    public String getGeneralStatistics(ModelMap model){
        model.addAttribute("listYearStatistics", generalStatisticsService.getListYearsStatistics());
        return "pub_stat";
    }

    private long getCurrentMonthStatisticsViews(ArrayList<YearStatistics> listYearsStatistics, long totalViews){
        long res = getCurrentYearStatisticsViews(listYearsStatistics, totalViews);
        ArrayList<Integer> currentYearStatisticsViews = listYearsStatistics.get(0).getYearViews();
        for (int i = 0; i < currentYearStatisticsViews.size(); i++) {
            res -= currentYearStatisticsViews.get(i);
        }
        return res;
    }

    private long getCurrentMonthStatisticsDownloads(ArrayList<YearStatistics> listYearsStatistics, long totalDownloads){
        long res = getCurrentYearStatisticsDownloads(listYearsStatistics, totalDownloads);
        ArrayList<Integer> currentYearStatisticsDownloads = listYearsStatistics.get(0).getYearDownloads();
        for (int i = 0; i < currentYearStatisticsDownloads.size(); i++) {
            res -= currentYearStatisticsDownloads.get(i);
        }
        return res;
    }

    private long getCurrentYearStatisticsViews(ArrayList<YearStatistics> listYearsStatistics, long totalViews){
        long res = totalViews;
        for (int i = 0; i < listYearsStatistics.size(); i++) {
            res -= listYearsStatistics.get(i).getTotalYearViews();
        }
        return res;
    }

    private long getCurrentYearStatisticsDownloads(ArrayList<YearStatistics> listYearsStatistics, long totalDownloads){
        long res = totalDownloads;
        for (int i = 0; i < listYearsStatistics.size(); i++) {
            res -= listYearsStatistics.get(i).getTotalYearDownloads();
        }
        return res;
    }
}
